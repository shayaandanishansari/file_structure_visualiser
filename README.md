# File Structure Creator
This is a simple and clean app that lets you create complex file structures visually and create it on your desired platform

![img.png](assets/img.png)

## INSTRUCTIONS
- Click on a node to select it. By default, a node is always selected
- Use the right panel buttons for adding child or sibling folders and files
- The top bar:
  - Write the desired output location for file structure creation (On Native Platforms)
  - Write the desired zip folder name for download (On Browser Platforms)
  - Use the download button to create/download respectively
  - Use the bin button to delete a node (also deletes it's children)

## DOWNLOAD
- Go to [website](https://shayaandanishansari.github.io/file_structure_visualiser/) for web use
- Go to [releases] to download for your native platform


*For Developers*

## DOWNLOAD AND RUN
- Requirements
  - install git on your native platform
  - install flutter and dependencies
- Clone the repo
  - git clone https://github.com/shayaandanishansari/file_structure_visualiser/ 
- Run
  - flutter run

## CODE STRUCTURE

lib <br>
|-- src <br>
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|-- models <br>
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|-- node.dart <br>
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|-- services <br> 
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|-- file_export <br>
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|-- file_export.dart <br>
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|-- file_export_io.dart <br>
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|-- file_export_web.dart <br>
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|-- file_export_unsupported.dart <br>
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|-- path utils.dart <br>
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|-- ui <br> 
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|-- tree_app.dart <br>
|-- main.dart <br>
