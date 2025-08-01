# Microsoft Store Submission Notes

## Changes Made to Address Rejection

The Microsoft Store rejected the application with the following feedback:
> The product crashes if run without elevated permissions at launch. If elevated permissions are required then include this requirement in the Description for the Store Listings. Please provide a quality title that is informative and accurate for users.

To address this issue, the following changes have been made:

1. **Updated Windows Manifest File**:
   - Added `requestedExecutionLevel` element with `level="requireAdministrator"` to explicitly request administrator privileges
   - File modified: `windows/runner/runner.exe.manifest`

2. **Created System Requirements Documentation**:
   - Created `SYSTEM_REQUIREMENTS.md` with detailed information about hardware and software requirements
   - Explicitly stated the need for administrator privileges on Windows
   - Included troubleshooting steps for users who experience crashes due to insufficient permissions

3. **Updated Store Listing Text**:
   - Updated app title to "AnnotateIt - Vision Annotation Tool (Admin Required)" to be more informative and clearly indicate admin requirement
   - Added admin requirement to the short description
   - Added prominent warning about admin requirement at the beginning of the long description
   - Kept the existing admin requirement in the system requirements section
   - These changes ensure the requirement is clearly visible in multiple places

4. **Updated README.md**:
   - Updated title to match the store listing for consistency
   - Maintained existing note about administrator privileges requirement on Windows

## Testing Instructions

Before submitting to the Microsoft Store, please test the application to ensure it works properly with the updated manifest:

1. Build the application:
   ```
   flutter build windows
   ```

2. Test running the application without administrator privileges:
   - The application should prompt for administrator privileges via the UAC dialog
   - If denied, the application should not crash but exit gracefully

3. Test running the application with administrator privileges:
   - The application should launch and function normally

## Submission Instructions

When submitting the application to the Microsoft Store:

1. Use the text from `STORE_LISTING.md` for the store listing
2. Ensure the "System Requirements" section clearly states that administrator privileges are required
3. Include screenshots that showcase the application's features

## Additional Notes

- The application requires administrator privileges because it needs to access system resources for database operations
- This is a common requirement for applications that need to write to protected directories or access certain system resources
- The changes made ensure that the application properly requests these privileges and informs users of this requirement