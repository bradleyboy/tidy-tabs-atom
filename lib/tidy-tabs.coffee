{CompositeDisposable} = require 'atom'
fs = require 'fs-plus'

module.exports = TidyTabs =
  config:
    runOnSave:
      title: 'Run on save'
      description: 'With this option enabled, Tidy Tabs runs every time a file is saved'
      type: 'boolean'
      default: false
    minimumTabs:
      title: 'Minimum number of tabs'
      description: 'Do not close tabs until there are more than this many tabs'
      type: 'integer'
      minimum: 1
      default: 4
    modifiedThreshold:
      title: 'Modified threshold'
      description: 'Do not close a tab if the file has been modified within this many minutes'
      type: 'integer'
      minimum: 1
      default: 15
    accessedThreshold:
      title: 'Accessed threshold'
      description: 'Do not close a tab if the file has been accessed within this many minutes'
      type: 'integer'
      minimum: 1
      default: 1

  activate: (state) ->
    @disposables = new CompositeDisposable

    @disposables.add atom.commands.add('atom-workspace', {
      'tidy-tabs:remove-stale-tabs': => this.tidy()
    })

    if atom.config.get('tidy-tabs.runOnSave')
      atom.workspace.observeTextEditors (editor) =>
        editor.onDidSave =>
            this.tidy()

  deactivate: ->
    @disposables.dispose()

  tidy: ->
    pane = atom.workspace.getActivePane()

    for item in this.getItemsToClose(pane)
      pane.destroyItem(item)

  # Determine if a file is a candidate for closing
  isCandidate: (pane, item) ->
    # Filter out non-buffer views, like the Settings panel
    unless item.getPath and item.isModified
      return false

    path = item.getPath()

    # Check if a file isn't saved yet, is the active item,
    # or has unsaved changes. Do this first to prevent
    # fs.statSync when possible
    if not path or item is pane.getActiveItem() or item.isModified()
      return false

    # Get last modifed and accessed times
    # Have to do this manually, as it doesn't seem to
    # be part of the Atom API(?)
    now = +new Date

    try
      stat = fs.statSync(path)
      lastModified = new Date(stat.mtime).getTime()
      lastAccessed = new Date(stat.atime).getTime()

      # Dirty hack to save this to the item so we
      # can sort later.
      item.__modified = lastModified

      # Test against modified/access thresholds
      now - lastModified > atom.config.get('tidy-tabs.modifiedThreshold')*60000 and
        now - lastAccessed > atom.config.get('tidy-tabs.accessedThreshold')*60000
    catch error
      return false

  getItemsToClose: (pane) ->
    items = pane.getItems()

    # Run items through isCandidate fn,
    # sort them by modified DESC and
    # slice off any leftover after tab threshold
    (item for item in items when this.isCandidate(pane, item))
      .sort (a,b) -> a.__modified < b.__modified ? -1 : 1
      .slice(atom.config.get('tidy-tabs.minimumTabs') - 1)
