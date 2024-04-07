# Test Environment

This is an environment for the Computer Architectures test project.

## Prerequisites (MacOS only)

If you don't have Homebrew installed, install it by running the following command in your terminal:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Then, in the same terminal, install dosbox-x:

```bash
brew install dosbox-x
```

!!! Relaunch your VS Code after installing dosbox-x !!!

## Preparing the Environment

To prepare the environment, follow these steps:

1. Clone the repository to your local machine.
2. Open the project in VS Code.
3. Install the suggested extensions, if you haven't already.

## Unlocking ASM Files

To unlock sample, follow these steps:

1. Open testenv/cmp.asm in VS Code editor.
2. Right click and select "Open Emulator"
3. In the emulator, type `unlock sample CODE123` (make sure to keep capitalization for the code)

This will take sample.bin, apply CODE123 unlocking code and save it as SAMPLE.ASM file in the root directory of the project.

## Running Tests

To run tests, follow these steps (for sample.asm):

1. In emulator, type `test sample` ("sample" is the name of the ASM file you want to test)
2. The emulator will run the test and display the results in the console.
