It seems like sooner or later you have to write a README. So here's the one for Iguana.

Iguana
======

Right now Iguana is a pile of random looking (but already quite well working!) code. Some day in the future it will become a static blog rendering engine to slay all other engines. Or something like that. 

Usage
-----

Make sure to edit the config.yaml such that the settings fit your setup.

### Creating a new article

To create a new article type 
   `ruby iguana.rb new article $FILENAME`

Iguana will generate an empty article template  named `YYYY_MM_DD_$FILENAME.markdown` in the "articles" folder. After the `META_END` tag in that file is where you want to write your article in Markdown syntax. Before the `META_END` tag is the metadata for the article; by now that's just the title and a list of tags, formatted with YAML.

### Rendering
To render the whole blog including the RSS-Feed, type 
   `ruby iguana.rb render all`
The rendered files can now be found in the "html" directory.