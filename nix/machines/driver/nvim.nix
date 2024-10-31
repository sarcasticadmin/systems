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
    git-rebase-auto-diff = pkgs.vimUtils.buildVimPlugin {
      pname = "git-rebase-auto-diff";
      version = "2023-08-14";
      src = pkgs.fetchFromGitHub {
        owner = "yutkat";
        repo = "git-rebase-auto-diff.nvim";
        rev = "ad95f18cb85c24ddc0b48bf190bc313dfc58e2d6";
        sha256 = "sha256-5g9VTpG1s9+/lojvRPRknLCzx2EguWUDl3u9unWxo6w=";
      };
     };
  in
  pkgs.neovim.override {
      vimAlias = true;
      #extraConfig = ''
      #  " your custom vimrc
      #  set nocompatible
      #  set backspace=indent,eol,start
      #  " ...
      #'';
      configure = {
        packages.myVimPackage = with pkgs.vimPlugins; {
         # we must include c, lua, vimdoc, vim to correct for the error:
         # query: invalid node type
         # ref: https://github.com/NixOS/nixpkgs/issues/282927
         start = [
           #{
           #  plugin = git-rebase-auto-diff;
	   #  type = "lua";
	   #  config = ''
           #    lua << EOF
#require('git-rebase-auto-diff').setup()
#EOF
#             '';
#	   }
           telescope-nvim
	   icansee
	   vibrantink
           {
             plugin = pkgs.vimPlugins.nvim-lspconfig;
             type = "lua";
             config = ''
	       lua << EOF
local lspconfig = require'lspconfig'
lspconfig.nixd.setup{}
lspconfig.rust_analyzer.setup {
  -- Server-specific settings. See `:help lspconfig-setup`
  settings = {
    ['rust-analyzer'] = {},
  },
}
opts = {
    inlay_hints = { enabled = true },
},
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
             plugin = pkgs.vimPlugins.nvim-treesitter.withPlugins (p: [ p.c p.lua p.vimdoc p.vim p.java p.terraform p.hcl p.rust ]);
             type = "lua";
	     #packadd! nvim-treesitter.lua
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
          set splitbelow
          set guicursor=n-v-c-i:block
          set backspace=2
          set mouse=
          set softtabstop=2 shiftwidth=2 expandtab
          "set autoindent
          "set smartindent

          " this broke colorschemes for me in nvim 0.10.0+
          " https://www.reddit.com/r/neovim/comments/1d66jlw/comment/l6qdrx7/
          set notermguicolors

          autocmd BufEnter * colorscheme vibrantink
          autocmd BufEnter *.nix colorscheme vibrantink
          autocmd BufEnter *.py colorscheme icansee
	  autocmd BufEnter *.rb colorscheme icansee
	  autocmd BufEnter *.tf* colorscheme icansee
	  autocmd BufEnter *.go colorscheme icansee
	  autocmd BufEnter *.rego colorscheme icansee

          " Set leader key to space
          let mapleader=" "

	  " Find files using Telescope command-line sugar.
	  nnoremap <leader>ff <cmd>Telescope find_files<cr>
	  nnoremap <leader>fg <cmd>Telescope live_grep<cr>
	  nnoremap <leader>fb <cmd>Telescope buffers<cr>
	  nnoremap <leader>fh <cmd>Telescope help_tags<cr>

	  " Using Lua functions
	  nnoremap <leader>ff <cmd>lua require('telescope.builtin').find_files()<cr>
	  nnoremap <leader>fg <cmd>lua require('telescope.builtin').live_grep()<cr>
	  nnoremap <leader>fb <cmd>lua require('telescope.builtin').buffers()<cr>
	  nnoremap <leader>fh <cmd>lua require('telescope.builtin').help_tags()<cr>

          " reopening a file at last position unless its an filetype for git
          " gitcommit and gitrebase are separate fts
          if has("autocmd") && &ft !~ "^git*"
            autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
              \| exe "normal! g'\"" | endif
          endif
        '';
      };
    };
}

