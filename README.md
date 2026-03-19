# Pkg2zip-Decrypted-Games-to-NoNpDrm-Zipped-Games

Automation scripts for compressing PlayStation Vita content into NoNpDrm-style ZIP archives ready for use with Vita3K.

This project is for **Windows 10/11 only**.

The strict requirements are having the correct folder structure based on `app`, `addcont`, and `patch`, and having a `TITLEID_NAME_MATCH.txt` file containing the title mapping used for final ZIP renaming.

Using **NPS Browser** and **pkg2zip** is optional, but strongly recommended because they make setup and preparation much easier.



## What This Project Does

This repository provides 3 batch-based compression workflows for already-unpacked PlayStation Vita content.

It is meant for content that already follows the expected structure and needs to be merged and compressed into a final archive ready for Vita3K.

Included variants:

- a BAT script that uses **WinRAR**
- a BAT script that uses **7-Zip**
- a BAT script that uses the built-in **Windows compression**

All three variants are intended to:

- process all detected `TITLEID` folders inside `app`
- check the source structure for each title
- merge base game, update, and DLC when present
- create a temporary Vita3K-ready structure
- compress the rebuilt content into a ZIP archive
- automatically rename the final ZIP through `TITLEID_NAME_MATCH.txt`
- skip recompression if the renamed final ZIP already exists
- delete the temporary folder after processing



## Requirements

### Common requirements

To use these scripts correctly, you need a main working folder containing:

- `app`
- `addcont`
- `patch`

You must also place inside that same main folder:

- the BAT file downloaded from this repository
- the `TITLEID_NAME_MATCH.txt` mapping file downloaded from this repository

Required final structure:

```text
folder
├─ addcont
│  └─ TITLEID
│     └─ DLC_FOLDER
│        └─ DLC files
├─ app
│  └─ TITLEID
│     └─ game files
├─ patch
│  └─ TITLEID
│     └─ patch files
├─ TITLEID_NAME_MATCH.txt
├─ chosen_version.bat
```
The exact tool used to create this structure does not matter.

You do not have to use NPS Browser or pkg2zip.

What matters is that the folders and files are already arranged correctly.

## Tool-specific requirements

 - WinRAR version — requires WinRAR.exe; supported in the script folder, a local WinRAR folder, standard install paths, or PATH.

 - 7-Zip version — requires 7z.exe; supported in the script folder, a local 7-Zip folder, standard install paths, or PATH.

 - Windows built-in version — no external software required, but less reliable for large archives.

Recommendation
WinRAR — recommended because it lets you monitor the progress of an ongoing compression process and handles large files properly.

 ## Recommended Preparation Tools
If you want a faster and easier workflow, you can use original external tools and guides to prepare the required folder structure:

 - NoPayStation FAQ: https://nopaystation.com/faq

 - pkg2zip (fork by lusid1): https://github.com/lusid1/pkg2zip

 - Alternative setup guide used as reference: https://www.cfwaifu.com/nopaystation/

The NoPayStation FAQ includes the original references for NPS Browser download and setup.

The CFWaifu guide is an alternative walkthrough to the guidance already available through the official NoPayStation resources.

If you choose to use NPS Browser together with pkg2zip, downloading the games and setting up the correct folder structure is usually much easier and faster.

1. Prepare the main working folder.
2. Right-click the game on NPS Browser.
3. Click Download All if available.
4. If Download All is not available, click Download and Unpack.
5. Then click Check for Patches.
6. Download the available patch for that title.

Following the previous instructions will lead you to have the exact structure necessary to make the BAT file work correctly.

## Quick Procedure

1. Go to your main working folder.
   
2. Set up your preferred external tools to download games and decompress them from .pkg to the right folder structure.
   
3. Make sure it contains app, addcont, and patch for your downloaded games.
   
4. Place the BAT file from this repository in the same folder.
   
5. Place TITLEID_NAME_MATCH.txt in the same folder.
    
6. Choose the BAT version you want to use:
  - WinRAR-based
  - 7-Zip-based
  - Windows built-in compression
    
7. Run the selected BAT file.

## Output Naming

Archives are first created using this raw format:

```text
TITLEID_Vita3K_Ready.zip
```
The final name is resolved through a batch subroutine that uses a small PowerShell lookup to read TITLEID_NAME_MATCH.txt, match the corresponding TITLEID, sanitize invalid Windows filename characters, and return the final archive name.

Example:

```text
PCSB00245_Vita3K_Ready.zip
```
becomes:
```text
Persona 4 Golden [EU].zip
```

If the final renamed ZIP already exists, the script skips it.

## What the Script Does

Once launched, the script will:

Detect the available compressor for the chosen version.

Read the list of TITLEID folders inside app.

Check the source structure for each title and display:

GAME = [X] or [ ]

UPDATE = [X] or [ ]

DLCS = [X] or [ ]

Check whether the final renamed ZIP already exists.

Check whether a raw TITLEID_Vita3K_Ready.zip already exists.

Create a temporary folder.

Rebuild the correct merged structure inside that temporary folder.

Compress the rebuilt result into a final ZIP archive.

Rename the ZIP using TITLEID_NAME_MATCH.txt.

Delete the temporary folder after compression is complete.

The final ZIP is intended to contain the merged result of:

the base game

the related update data

the related DLC data

Limitations
The script depends on the correctness of the source folder structure.

Automatic final renaming depends on TITLEID_NAME_MATCH.txt.

If a title is missing from the mapping file, the script can still create the raw ZIP, but it may keep the TITLEID_Vita3K_Ready.zip name.

Some game names may need character cleanup because Windows filenames do not allow certain characters.

The Windows built-in compression variant is the most limited option and may not work reliably with games larger than about 2 GB.

Notes
Windows only.

This repository does not redistribute NPS Browser, pkg2zip, WinRAR, 7-Zip, or other third-party tools.

Please obtain any optional external dependency only from its original source.

The only strict requirements are the correct folder structure and the presence of TITLEID_NAME_MATCH.txt.

NPS Browser and pkg2zip are optional, but strongly recommended for convenience and speed.

The generated archive is designed as a NoNpDrm-style merged ZIP intended for Vita3K use.

This project was developed with AI assistance. [cite:198]

License
This repository is licensed under a custom non-commercial attribution license. See the LICENSE file for full terms. For permissions and exceptions, contact andreabietti.business@gmail.com.
