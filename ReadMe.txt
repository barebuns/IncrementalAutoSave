Add defunc01.lsp to your sd_customize file to autoload this quicksave tool.
Add am_autosave.lsp to your am_customize file to add Annotation quicksave.
Note that Quick Autosave, AutoSave Baseline, AutoSave Incremental, and Open AutoSave Dir are in your toolbox, and Quick Autosave is an available command to add to your toolbar.

In Creo Modeling (CoCreate SolidDesigner), just using this toolset's "baseline" save instead of the standard autosave is a great time saver, since you don't have to wait for the package file to zip (why don't they do that in the background?). This toolset saves a baseline save using .sd? format to the user's temp directory. 

Current suggested usage is to turn on Modeling's Autosave function with the 'ask before save' option. When it asks if you want to save now, say no, then use these tools. The first time per Modeling session the Quick Autosave function will do an AutoSaveBaseline; each baseline also creates a copy upon completion to fallback to. Subsequent clicks on Quick Autosave calles the AutoSaveIncremental; it will be substantially quicker as it only saves items that have changed; current code cycles through 3 copies of autosaves to fallback to. 

For best safety in testing phase, consider doing a new baseline save when heading out to lunch, a meeting, or other opportunity where the delay of the save won't be an irritation. This frequent number of copies of design space have the potential to quickly fill up your hard drive - OpenAutoSaveDir will take you to the Autosave base directory where you can delete old unneeded directories. 

To recover in the case of crash you can go to the most recent autosave directory, sort by file type and load .sd? files, i.e. .sdw, .sdp, .sda, etc. Don't load .sd?c files unless you are only after a particular instance of part/assy/WP.