// Defines dialog IDs using an enum.  Enums are preferred since they automatically
// assign unique values (IDs), eliminating the need to manually track them.
//
// Avoid using magic numbers for dialog IDs - it quickly becomes unclear what
// each value represents.
enum
{
    DIALOG_NO_RESPONSE,

    DIALOG_REGISTRATION,
    DIALOG_LOGIN
};