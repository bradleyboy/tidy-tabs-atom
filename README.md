# Tidy Tabs for Atom

## Why and how
Ever get to the end (middle?) of a day of coding only to find your window littered with tabs that are nearly impossible to search through visually? Find yourself rage-quitting all your tabs in disgust and starting over? No? Just me? Ok.

With this plugin, a simple keystroke `ctrl + alt + shift + w` will close all tabs whose file has not been modified in the last 15 minutes (to change this interval, see *Configuration* below). It will only close tabs in the background – so files that are open and active in your window won't be closed. Likewise, it will not close files with unsaved changes.

You can also configure the plugin to run automatically.

## Configuration

You can configure the plugin by opening the Atom Settings pane, then clicking *Packages* in the left column, then searching for *tidy-tabs*. Click the *Settings* gear to make changes to the configuration.

### Configuration options

#### Accessed threshold
Do not close tabs that have been accessed in the last *n* minutes.

#### Miniumum tabs
Do not close tabs until there are more than this number of tabs open in the given pane.

#### Modified threshold
Do not close tabs that have been modified in the last *n* minutes.

#### Run on save
When enabled, Tidy Tabs will run every time a file is saved.
