vim.o.clipboard = "unnamedplus"

-- Initialize Packer
require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'  -- Packer manages itself

    -- Telescope: Fuzzy Finder
    use {
        'nvim-telescope/telescope.nvim',
        requires = { {'nvim-lua/plenary.nvim'} },
        config = function()
            require('telescope').setup{}
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
                    width = 30,          -- Width of the tree
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
                open_mapping = [[<C-c>]],  -- Open/close terminal with Ctrl-C
            }
        end
    }
end)

-- Keybindings
vim.api.nvim_set_keymap('n', '<C-n>', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>ff', '<cmd>Telescope find_files<CR>', { noremap = true, silent = true })

-- Optional: Remove Redundant Terminal Mapping
-- This is handled by ToggleTerm's `open_mapping`.
-- vim.api.nvim_set_keymap('n', '<C-c>', ':split | terminal<CR>', { noremap = true, silent = true })

-- Remap delete commands to avoid affecting the system clipboard
vim.api.nvim_set_keymap('n', 'd', '"_d', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'dd', '"_dd', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 's', '"_s', { noremap = true, silent = true })
vim.api.nvim_set_keymap('x', 'd', '"_d', { noremap = true, silent = true }) -- Visual mode
vim.api.nvim_set_keymap('n', 'D', '"_D', { noremap = true, silent = true }) -- Capital D

