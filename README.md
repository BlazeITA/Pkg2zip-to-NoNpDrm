# Pkg2zip-Decrypted-Games-to-NoNpDrm-Zipped-Games

Automation scripts for compressing PlayStation Vita content into NoNpDrm-style ZIP archives ready for use with Vita3K.

This project is for **Windows only**.

The only real requirement is having the correct folder structure based on `app`, `addcont`, and `patch`.

Using **NPS Browser** and **pkg2zip** is optional, but strongly recommended because they make setup and preparation much easier.



## What This Project Does

This repository provides 3 batch-based compression workflows for already-unpacked PlayStation Vita content.

It is meant for content that already follows the expected structure and needs to be merged and compressed into a final archive ready for Vita3K.

Included variants:

- a BAT script that uses **WinRAR**
- a BAT script that uses **7-Zip**
- a BAT script that uses the built-in **Windows compression**

The built-in Windows compression version does not require external software, but it has major size limitations and may fail with games larger than about 2 GB.



## Everything you need to know

To use these scripts correctly, you need a main folder containing:

- `app`
- `addcont`
- `patch`

You must also place the BAT file downloaded from this repository inside that same main folder.

Required structure:

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
```

The exact tool used to create this structure does not matter.

You do not have to use NPS Browser or pkg2zip.

What matters is that the folders and files are already arranged correctly.

Quick Procedure

1. Prepare a main working folder.
2. Set up your preferred external tools to download games and decompress them from .pkg to the right folder structure.
2. Make sure it contains app, addcont, and patch of your downloaded games.
3. Place the BAT file from this repository in the same folder.
4. Choose the BAT version you want to use:
-WinRAR-based
-7-Zip-based
-Windows built-in compression
5. Run the selected BAT file.

What the Script Does

Once launched, the script will:

1. Inspect the subfolders inside app, addcont, and patch, checking that the titleid has not already been compressed. If it has already been compressed, skip the TitleID.
2. Use the TitleID as the main matching reference.
3. Create a temporary folder.
4. Rebuild the correct merged structure inside that temporary folder.
5. Compress the rebuilt result into a final ZIP archive.
6. Delete the temporary folder after compression is complete.

Output
The final archive is generated using this format:

text
TITLEID_Vita3k_ready.zip

The ZIP is intended to contain the merged result of:

the base game
the related update data
the related DLC data

Recommended Preparation Tools
This repository does not include direct external setup tools downloads.

If you want a faster and easier workflow, you can use original external tools and guides to prepare the required folder structure:

NoPayStation FAQ: https://nopaystation.com/faq

pkg2zip (fork by lusid1): https://github.com/lusid1/pkg2zip

Alternative setup guide used as reference: https://www.cfwaifu.com/nopaystation/

The NoPayStation FAQ includes the original references for NPS Browser download and setup.

The CFWaifu guide is an alternative walkthrough to the guidance already available through the official NoPayStation resources.

If you choose to use NPS Browser together with pkg2zip, the preparation phase is usually much easier and faster.

1. Right-click the game.
2. Click **Download All** if available.
3. If **Download All** is not available, click **Download and Unpack**.
4. Then click **Check for Patches**.
5. Download the available patch for that title.

Once the preparation is complete, open the configured output folder and run the BAT file of your choice.

Limitations
Unfortunately, it was not possible to automatically replace the TitleID with the real game name in the final ZIP filename.

This is because the folder structure does not provide a constant and reliable reference to the actual game name.

If you want a more readable filename, you can manually rename the final ZIP after creation.

The Windows built-in compression variant is the most limited option and may not work reliably with games larger than about 2 GB.

## Notes

- Windows only.
- This repository does not redistribute NPS Browser, pkg2zip, WinRAR, 7-Zip, or other third-party tools.
- Please obtain any optional external dependency only from its original source.
- The only strict requirement is the correct folder structure.
- NPS Browser and pkg2zip are optional, but strongly recommended for convenience and speed.
- The generated archive is designed as a NoNpDrm-style merged ZIP intended for Vita3K use.

## License

This repository is licensed under a custom non-commercial attribution license. See the LICENSE file for full terms. For permissions and exceptions, contact andreabietti.business@gmail.com.
