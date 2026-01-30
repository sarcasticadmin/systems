{ pkgs, config, ...}:
{
  environment = {
    systemPackages = with pkgs; [
      config.programs.vim.package
      nixd
      rust-analyzer
      ripgrep
   ];
  };

  programs.vim.package = let
    icansee = pkgs.vimUtils.buildVimPlugin {
      pname = "icansee.vim";
      version = "2020-08-14";
      src = pkgs.fetchFromGitHub {
        owner = "vim-scripts";
        repo = "icansee.vim";
        rev = "96e86e5b508fa1f833c5419a564e32d72a19c625";
        sha256 = "sha256-wV9OW1n0GFWf5Rz6BprvcSz0W6yRw7gbSFwudST4L3U=";
      };
     };
    vibrantink = pkgs.vimUtils.buildVimPlugin {
      pname = "vibrantink.vim";
      version = "2020-08-14";
      src = pkgs.fetchFromGitHub {
        owner = "vim-scripts";
        repo = "vibrantink";
        rev = "f7777656a73b7209b111e9cbd71945c315220500";
        sha256 = "sha256-gwdlCsJrmBPypOOkLCBNF/5/XdrvYBjVc718BsMkgfA=";
      };
     };
    vibrantink2 = pkgs.vimUtils.buildVimPlugin {
      pname = "vibrantink2.vim";
      version = "2021-11-02";
      src = pkgs.fetchFromGitHub {
        owner = "afair";
        repo = "vibrantink2";
        rev = "a6ec4aa432a16a0e10d5ee274a35e88fc65d00d0";
        sha256 = "sha256-oANeUx4uXtkG3VxYhn+8W63Yvz5g9ISrL9JXsJxFMB4=";
      };
     };
  in
  pkgs.neovim.override {
      vimAlias = true;
      configure = {
        packages.myVimPackage = with pkgs.vimPlugins; {
         start = [
            telescope-nvim
            icansee
            vibrantink
            vibrantink2
            SpaceCamp
            {
              # plugin needed to configure lsp with things like root file hints, etc.
              plugin = pkgs.vimPlugins.nvim-lspconfig;
              type = "lua";
              config = ''
                lua << EOF
vim.lsp.enable("nixd")
                                                                                                                           -- rust-analyzer
vim.lsp.config("rust_analyzer", {
  settings = {
    ["rust-analyzer"] = {},
  },
  inlay_hints = {
    enabled = true,
  },
})

vim.lsp.enable("rust_analyzer")

-- enable inlay hints
vim.lsp.inlay_hint.enable(true)

--ensure that lsp doesnt mess with colorscheme
--https://www.reddit.com/r/neovim/comments/zjqquc/comment/izwahv7/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    client.server_capabilities.semanticTokensProvider = nil
  end,
});
EOF
              '';
            }
            {

              plugin = pkgs.vimPlugins.vim-better-whitespace;
              type = "lua";
              config = ''
                lua << EOF
vim.g.better_whitespace_ctermcolor = "lightgrey"
vim.g.strip_whitespace_on_save = 1
vim.g.strip_only_modified_lines = 1
vim.g.strip_whitespace_confirm = 0
EOF
              '';
            }
            {
              # we must include c, lua, vimdoc, vim to correct for the error:
              # query: invalid node type
              # ref: https://github.com/NixOS/nixpkgs/issues/282927
              plugin = pkgs.vimPlugins.nvim-treesitter.withPlugins (p: [
                p.bash
                p.c
                p.go
                p.hcl
                p.java
                p.lua
                p.nix
                p.perl
                p.rust
                p.terraform
                p.vim
                p.vimdoc
              ]);
              type = "lua";
              config = ''
	        lua << EOD
require('nvim-treesitter.configs').setup {
  highlight = { enable = true},
  indent = { enable = true}
}
EOD
              '';
            }
          ];
        };
	customRC = ''
          lua << EOF
-- vim.opt if for things you would set in vimscript. vim.g is for things you'd let
vim.opt.splitbelow = true
vim.opt.guicursor = 'n-v-c-i:block'
-- equivalent of set backspace=2
vim.opt.backspace = {'indent', 'eol', 'start'}
vim.opt.mouse = ""
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- put the lsp signs inline with the numbers
vim.opt.number = true
vim.opt.signcolumn = "number"

-- this broke colorschemes for me in nvim 0.10.0+
-- https://www.reddit.com/r/neovim/comments/1d66jlw/comment/l6qdrx7/
vim.opt.termguicolors = false

-- autocmd BufEnter * colorscheme vibrantink
-- autocmd BufEnter *.nix colorscheme vibrantink
-- autocmd BufEnter *.py colorscheme icansee
-- autocmd BufEnter *.rb colorscheme icansee
-- autocmd BufEnter *.tf* colorscheme icansee
-- autocmd BufEnter *.go colorscheme icansee
-- autocmd BufEnter *.rego colorscheme icansee

-- :lua vim.cmd.colorscheme() to see current colorscheme
-- :lua print(vim.bo.filetype) to see current filetype
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    vim.cmd("colorscheme vibrantink2")
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python", "terraform" },
  callback = function()
    vim.cmd("colorscheme icansee")
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    vim.cmd("colorscheme spacecamp")
  end,
})
-- Set leader key to space
vim.g.mapleader = " "

-- Find files using Telescope
vim.keymap.set('n', '<Leader>ff', require('telescope.builtin').find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<Leader>fg', require('telescope.builtin').live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<Leader>fb', require('telescope.builtin').buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<Leader>fh', require('telescope.builtin').help_tags, { desc = 'Telescope help tags' })
        '';
      };
    };
}

