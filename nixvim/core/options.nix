{ ... }:

{
  globals = {
    mapleader = " ";
    maplocalleader = " ";
    format_on_save = true;
  };

  opts = {
    clipboard = "unnamedplus";
    updatetime = 200;
    timeoutlen = 300;
    termguicolors = true;
    undofile = true;
    undolevels = 10000;
    signcolumn = "yes";
    number = true;
    relativenumber = true;
    cursorline = true;
    expandtab = true;
    tabstop = 2;
    shiftwidth = 2;
    shiftround = true;
    smartindent = true;
    ignorecase = true;
    smartcase = true;
    inccommand = "split";
    splitbelow = true;
    splitright = true;
    showmode = false;
    wrap = false;
    mouse = "a";
    scrolloff = 8;
    sidescrolloff = 8;
    smoothscroll = true;
    confirm = true;
    conceallevel = 2;
    pumheight = 12;
    winborder = "rounded";
    foldcolumn = "1";
    foldlevel = 99;
    foldlevelstart = 99;
    foldenable = true;
    foldmethod = "expr";
    foldexpr = "v:lua.vim.treesitter.foldexpr()";
    foldtext = "v:lua.DynaFoldText()";
    completeopt = [ "menu" "menuone" "noselect" ];
    fillchars = {
      eob = " ";
      foldopen = "▾";
      foldclose = "▸";
      fold = " ";
      foldsep = " ";
      diff = "╱";
    };
  };
}
