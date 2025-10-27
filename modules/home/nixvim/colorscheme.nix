{theme, ...}:
with theme;
with theme.normal; {
  programs.nixvim.highlight = {
    # group-name
    Comment = {
      fg = lightgray;
      italic = true;
    };
    Constant.fg = blue;
    String.fg = green;
    Character.fg = green;
    Number.fg = orange;
    Boolean.fg = orange;
    Float.fg = orange;
    Identifier.fg = white;
    Function.fg = blue;
    Statement.fg = magenta;
    Conditional.fg = magenta;
    Repeat.fg = magenta;
    Label.fg = red;
    Operator.fg = magenta;
    Keyword.fg = magenta;
    Exception.fg = magenta;
    PreProc.fg = blue;
    Include.fg = magenta;
    Define.fg = magenta;
    Macro.fg = magenta;
    PreCondit.fg = yellow;
    Type.fg = yellow;
    StorageClass.fg = yellow;
    Structure.fg = yellow;
    Typedef.fg = yellow;
    Special.fg = blue;
    SpecialChar.fg = orange;
    Tag = {};
    Delimiter = {};
    SpecialComment = {
      fg = lightgray;
      italic = true;
    };
    Debug = {};
    Underlined.underline = true;
    Ignore = {};
    Error.fg = red;
    Todo.fg = magenta;

    # highlight-groups
    ColorColumn.bg = dimgray;
    Conceal = {};
    Cursor = {
      fg = black;
      bg = blue;
    };
    lCursor = {
      fg = black;
      bg = cyan;
    };
    CursorIM.fg = white;
    CursorColumn.bg = dimgray;
    CursorLine.bg = dimgray;
    Directory.fg = blue;
    DiffAdd.fg = green;
    DiffChange.fg = yellow;
    DiffDelete.fg = red;
    DiffText.fg = white;
    EndOfBuffer.fg = black;
    TermCursor.bg = white;
    TermCursorNC.fg = white;
    ErrorMsg.fg = red;
    WinSeparator.fg = black;
    Folded.fg = lightgray;
    FoldColumn.fg = white;
    SignColumn.fg = white;
    IncSearch = {
      fg = yellow;
      bg = lightgray;
    };
    Substitute = {
      fg = black;
      bg = yellow;
    };
    LineNr.fg = silver;
    CursorLineNr.fg = white;
    MatchParen = {
      fg = blue;
      underline = true;
    };
    ModeMsg.fg = white;
    MsgArea.fg = white;
    MsgSeparator.fg = dimgray;
    MoreMsg.fg = white;
    NonText.fg = silver;
    # Main background, set to NONE for transparency.
    Normal = {
      fg = foreground;
      # bg = background;
      bg = "NONE";
    };
    NormalFloat = {
      fg = white;
      bg = dimgray;
    };
    NormalNC = {
      fg = foreground;
      # bg = background-defocused;
      bg = "NONE";
    };
    Pmenu = {
      fg = white;
      bg = dimgray;
    };
    PmenuSel = {
      fg = black;
      bg = blue;
    };
    PmenuSbar.bg = dimgray;
    PmenuThumb.bg = lightgray;
    Question.fg = magenta;
    QuickFixLine = {
      fg = black;
      bg = yellow;
    };
    Search = {
      fg = black;
      bg = yellow;
    };
    SpecialKey.fg = silver;
    SpellBad = {
      fg = red;
      underline = true;
    };
    SpellCap.fg = orange;
    SpellLocal.fg = orange;
    SpellRare.fg = orange;
    StatusLine = {};
    StatusLineNC = {};
    TabLine.fg = lightgray;
    TabLineFill = {};
    TabLineSel.fg = white;
    Title = {
      fg = blue;
      bold = true;
    };
    Visual = {
      reverse = true;
    };
    VisualNOS.bg = gray;
    WarningMsg.fg = yellow;
    Whitespace.fg = silver;
    WildMenu = {
      fg = black;
      bg = blue;
    };

    # nvim_open_win
    FloatBorder = {
      fg = white;
      bg = dimgray;
    };

    # diagnostic
    DiagnosticError.fg = red;
    DiagnosticWarn.fg = yellow;
    DiagnosticInfo.fg = blue;
    DiagnosticHint.fg = white;
    DiagnosticUnderlineError = {
      sp = red;
      underline = true;
    };
    DiagnosticUnderlineWarn = {
      sp = yellow;
      underline = true;
    };
    DiagnosticUnderlineInfo = {
      sp = blue;
      underline = true;
    };
    DiagnosticUnderlineHint = {
      sp = white;
      underline = true;
    };

    # diff
    diffRemoved.fg = red;
    diffAdded.fg = green;
    diffChanged.fg = yellow;
    diffSubname.fg = orange;
    diffLine.fg = magenta;
    diffFile.fg = yellow;
    diffOldFile.fg = red;
    diffNewFile.fg = green;
    diffIndexLine.fg = magenta;

    # gitsigns.nvim
    GitSignsAdd.fg = green;
    GitSignsChange.fg = yellow;
    GitSignsDelete.fg = red;

    # indent-blankline.nvim
    IndentBlanklineChar.fg = gray;

    # leap.nvim
    LeapMatch = {
      fg = green;
      bold = true;
    };
    LeapLabelPrimary = {
      fg = black;
      bg = blue;
      bold = true;
    };
    LeapLabelSecondary = {
      fg = white;
      bg = yellow;
      bold = true;
    };
    LeapLabelSelected = {
      fg = magenta;
      bold = true;
    };
    LeapBackdrop = {
      fg = lightgray;
      bg = black;
    };

    # lsp-semantic-highlight
    "@lsp.type.attributeBracket".fg = cyan;
    "@lsp.type.builtinAttribute".fg = cyan;
    "@lsp.type.class".fg = yellow;
    "@lsp.type.comment" = {
      fg = lightgray;
      italic = true;
    };
    "@lsp.type.decorator".fg = cyan;
    "@lsp.type.deriveHelper".fg = cyan;
    "@lsp.type.enum".fg = yellow;
    "@lsp.type.enumMember".fg = orange;
    "@lsp.type.event".fg = orange;
    "@lsp.type.function".fg = blue;
    "@lsp.type.interface".fg = yellow;
    "@lsp.type.keyword".fg = magenta;
    "@lsp.type.macro".fg = blue;
    "@lsp.type.method".fg = blue;
    "@lsp.type.modifier".fg = magenta;
    "@lsp.type.namespace".fg = white;
    "@lsp.type.number".fg = orange;
    "@lsp.type.operator".fg = magenta;
    "@lsp.type.parameter".fg = red;
    "@lsp.type.property".fg = blue;
    "@lsp.type.regexp".fg = orange;
    "@lsp.type.string".fg = green;
    "@lsp.type.struct".fg = yellow;
    "@lsp.type.type".fg = yellow;
    "@lsp.type.typeParameter".fg = red;
    "@lsp.type.variable".fg = white;
    "@lsp.typemod.function.builtin".fg = cyan;
    "@lsp.typemod.struct.builtin".fg = orange;

    # neo-tree.nvim
    NeoTreeDimText.fg = lightgray;
    NeoTreeDirectoryIcon.fg = white;
    NeoTreeDotfile.fg = lightgray;
    NeoTreeFloatBorder = {
      fg = white;
      bg = black;
    };
    NeoTreeFloatNormal = {
      fg = white;
      bg = black;
    };
    NeoTreeGitConflict.fg = lightred;
    NeoTreeGitUnstaged.fg = orange;
    NeoTreeGitUntracked.fg = orange;

    # noice.nvim
    NoiceFormatProgressDone = {
      fg = white;
      bg = silver;
    };
    NoiceFormatProgressTodo = {
      fg = white;
      bg = black;
    };
    NoiceLspProgressTitle.fg = white;

    # nvim-cmp
    CmpItemAbbr.fg = white;
    CmpItemAbbrDeprecated.fg = lightgray;
    CmpItemAbbrMatch.fg = blue;
    CmpItemAbbrMatchFuzzy.fg = blue;
    CmpItemKind.fg = orange;
    CmpItemMenu.fg = white;

    # nvim-notify
    NotifyERRORBorder.fg = red;
    NotifyERRORIcon.fg = red;
    NotifyERRORTitle.fg = red;
    NotifyWARNBorder.fg = yellow;
    NotifyWARNIcon.fg = yellow;
    NotifyWARNTitle.fg = yellow;
    NotifyINFOBorder.fg = blue;
    NotifyINFOIcon.fg = blue;
    NotifyINFOTitle.fg = blue;
    NotifyDEBUGBorder.fg = white;
    NotifyDEBUGIcon.fg = white;
    NotifyDEBUGTitle.fg = white;
    NotifyTRACEBorder.fg = white;
    NotifyTRACEIcon.fg = white;
    NotifyTRACETitle.fg = white;
    NotifyBackground.bg = background;

    # telescope.nvim
    TelescopeResultsIdentifier.fg = blue;

    # treesitter
    "@attribute".fg = cyan;
    "@constant.builtin".fg = orange;
    "@constant.macro".fg = orange;
    "@constructor".fg = yellow;
    "@error".fg = red;
    "@field".fg = blue;
    "@function.builtin".fg = cyan;
    "@function.macro".fg = blue;
    "@namespace".fg = white;
    "@none".fg = white;
    "@parameter".fg = red;
    "@property".fg = blue;
    "@punctuation.delimiter".fg = white;
    "@punctuation.special".fg = blue;
    "@string.escape".fg = orange;
    "@string.regex".fg = orange;
    "@string.special".fg = orange;
    "@symbol".fg = cyan;
    "@tag".fg = blue;
    "@tag.attribute".fg = red;
    "@tag.delimiter".fg = blue;
    "@text.danger".fg = red;
    "@text.emphasis".italic = true;
    "@text.literal".fg = green;
    "@text.note".fg = blue;
    "@text.reference".fg = red;
    "@text.strong".bold = true;
    "@text.title" = {
      fg = blue;
      bold = true;
    };
    "@text.uri".fg = orange;
    "@text.warning".fg = yellow;
    "@type".fg = yellow;
    "@type.qualifier".fg = magenta;
    "@variable.builtin".fg = orange;

    # custom
    StatusLineGitAdded = {
      fg = green;
      bg = dimgray;
    };
    StatusLineGitChanged = {
      fg = yellow;
      bg = dimgray;
    };
    StatusLineGitRemoved = {
      fg = red;
      bg = dimgray;
    };
  };
}
