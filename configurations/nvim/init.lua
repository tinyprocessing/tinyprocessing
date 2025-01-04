vim.o.clipboard = "unnamedplus"

-- Show invisibles
vim.o.list = true
vim.o.listchars = "tab:>-,trail:~,extends:>,precedes:<,nbsp:+"

-- Initialize Packer
require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'  -- Packer manages itself
    -- Telescope: Fuzzy Finder
    -- Telescope: Fuzzy Finder
    use {
        'nvim-telescope/telescope.nvim',
        requires = { {'nvim-lua/plenary.nvim'} },
        config = function()
            require('telescope').setup{
                defaults = {
                    file_ignore_patterns = {"node_modules", ".git", ".pbxproj", ".xcodeproj"},
                },
                pickers = {
                    find_files = {
                        theme = "dropdown",
                    },
                    live_grep = {
                        theme = "dropdown",
                    },
                },
            }
        end
    }

    -- Gitsigns: Git Integration
    use {
        'lewis6991/gitsigns.nvim',
        config = function()
            require('gitsigns').setup()
        end
    }

    -- Nvim-Tree: File Explorer
    use {
        'nvim-tree/nvim-tree.lua',
        requires = {
            'nvim-tree/nvim-web-devicons', -- Optional for file icons
        },
        config = function()
            require('nvim-tree').setup {
                view = {
                    width = 40,          -- Width of the tree
                    side = 'left',       -- Tree on the left side
                },
                renderer = {
                    icons = {
                        show = {
                            git = true,  -- Show Git status icons
                            file = true, -- Show file icons
                            folder = true, -- Show folder icons
                        },
                    },
                },
            }
        end
    }

    -- ToggleTerm: Terminal Integration
    use {
        'akinsho/toggleterm.nvim',
        config = function()
            require('toggleterm').setup {
                direction = 'horizontal',
                size = 15,
                open_mapping = '<leader>t',
            }
        end
    }

    -- LSP Config
    use {
        'neovim/nvim-lspconfig',
        config = function()
            local lspconfig = require('lspconfig')

            -- Configure SourceKit LSP for Swift
            lspconfig.sourcekit.setup {
                cmd = { "sourcekit-lsp" },
                filetypes = { "swift", "objective-c", "objective-cpp" },
                root_dir = lspconfig.util.root_pattern(".git", "Package.swift"),
            }
        end
    }

    -- Autocomplete (nvim-cmp)
    use {
        'hrsh7th/nvim-cmp',
        requires = {
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-cmdline',
            'hrsh7th/cmp-vsnip',        -- Snippet support
            'hrsh7th/vim-vsnip',
        },
        config = function()
            local cmp = require'cmp'
            cmp.setup {
                snippet = {
                    expand = function(args)
                        vim.fn["vsnip#anonymous"](args.body)
                    end,
                },
                mapping = {
                    ['<C-Space>'] = cmp.mapping.complete(),              -- Trigger completion manually
                    ['<CR>'] = cmp.mapping.confirm({ select = true }),   -- Confirm selection
                    ['<Up>'] = cmp.mapping.select_prev_item(),           -- Navigate up
                    ['<Down>'] = cmp.mapping.select_next_item(),         -- Navigate down
                    ['<C-p>'] = cmp.mapping.select_prev_item(),          -- Navigate up (alternative)
                    ['<C-n>'] = cmp.mapping.select_next_item(),          -- Navigate down (alternative)
                },
                sources = {
                    { name = 'nvim_lsp' },
                    { name = 'buffer' },
                    { name = 'path' },
                },
            }
        end
    }
end)

-- Keybindings
vim.api.nvim_set_keymap('n', '<C-n>', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>ff', '<cmd>Telescope find_files<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>fr', ':NvimTreeFindFile<CR>', { noremap = true, silent = true })

-- Keybindings for Telescope
vim.api.nvim_set_keymap('n', '<leader>fg', '<cmd>Telescope live_grep<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>fd', '<cmd>Telescope lsp_definitions<CR>', { noremap = true, silent = true })


-- Remap delete commands to avoid affecting the system clipboard
vim.api.nvim_set_keymap('n', 'd', '"_d', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'dd', '"_dd', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 's', '"_s', { noremap = true, silent = true })
vim.api.nvim_set_keymap('x', 'd', '"_d', { noremap = true, silent = true }) -- Visual mode
vim.api.nvim_set_keymap('n', 'D', '"_D', { noremap = true, silent = true }) -- Capital D

-- Quick toggle between terminal and editor
vim.api.nvim_set_keymap('n', '<C-q>', '<C-w>j<CR>:startinsert<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('t', '<C-q>', [[<C-\><C-N><C-w>k]], { noremap = true, silent = true })
vim.cmd([[autocmd TermEnter * startinsert]])

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
    command = "checktime",
})

-- Enable line numbers
vim.o.number = true
vim.o.relativenumber = true

-- Enable case-insensitive search
vim.o.ignorecase = true
vim.o.smartcase = true

