permissionset 87090 WANAPORT
{
    Caption = 'WanaPort';
    Assignable = true;
    Permissions = tabledata WanaPort = RIMD,
        tabledata "WanaPort Field Constant" = RIMD,
        tabledata "WanaPort Field Value Map" = RIMD,
        tabledata "WanaPort Log" = RIMD,
        table WanaPort = X,
        table "WanaPort Field Constant" = X,
        table "WanaPort Field Value Map" = X,
        table "WanaPort Log" = X,
        codeunit "WanaPort Export" = X,
        codeunit "WanaPort Import" = X,
        codeunit "WanaPort Management" = X,
        codeunit "WanaPort Relation" = X,
        page "WanaPort Card" = X,
        page "WanaPort Field Constant" = X,
        page "WanaPort Field Value Map" = X,
        page "WanaPort File List" = X,
        page "WanaPort Job Queue" = X,
        page "WanaPort Log" = X,
        page wanaPorts = X;
}