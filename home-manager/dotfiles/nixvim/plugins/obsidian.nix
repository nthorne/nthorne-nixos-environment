{...}: {
  programs.nixvim = {
    plugins = {
      obsidian = {
        enable = true;
        settings = {
          legacy_commands = false;

          workspaces = [
            {
              name = "notes";
              path = "/home/nthorne/repos/notes/";
            }
          ];
          notes_subdir = "0.inbox";
          new_notes_location = "notes_subdir";

          daily_notes = {
            folder = "5.daily/log";
            date_format = "%Y%m%d";
            template = "3.templates/Daily.md";
          };

          completion = {
            nvim_cmp = true;
            min_chars = 2;
          };

          note_id_func.__raw = ''
              function(title)
                return os.date("%Y%m%d%H%M") .. " " .. title
              end
              '';

          wiki_link_func = "prepend_note_path";
          preferred_link_style = "wiki";
          use.frontmatter = false;

          templates = {
            folder = "3.templates";
            date_format = "%Y-%m-%d";
            time_format = "%H:%M";
            substitutions = {};
          };

          follow_url_func.__raw = ''
            function(url)
              vim.ui.open(url)
            end
            '';

          follow_img_func.__raw = ''
            function(img)
              vim.fn.jobstart({"xdg-open", url})
            end
            '';

          picker = {
            name = "telescope.nvim";
            note_mappings = {
              # Create a new note from your query.
              new = "<C-x>";
              # Insert a link to the selected note.
              insert_link = "<C-l>";
            };
            tag_mappings = {
              # Add tag(s) to current note.
              tag_note = "<C-x>";
              # Insert a tag at the current location.
              insert_tag = "<C-l>";
            };
            sort_by = "modified";
            sort_reversed = true;
            search_max_lines = 1000;

            # Specify how to handle attachments.
            attachments = {
              img_folder = "8.assets";

              img_name_func.__raw = ''
               function()
                 -- Prefix image names with timestamp.
                 return string.format("%s ", os.time())
               end
               '';

              # A function that determines the text to insert in the note when pasting an image.
              # It takes two arguments, the `obsidian.Client` and an `obsidian.Path` to the image file.
              # This is the default implementation.
              # @param client obsidian.Client
              # @param path obsidian.Path the absolute path to the image file
              # @return string
              img_text_func.__raw = ''
              function(client, path)
                path = client:vault_relative_path(path) or path
                return string.format("![%s](%s)", path.name, path)
              end
              '';
            };
          };
        }; 
      };
    };
    # NOTE: I had to put these as autocmds, because callback functionality did not
    #       work, and I couldn't figure out how to set visual mode keymaps in mappings..
    autoCmd = [
      {
        event = "User";
        pattern = "ObsidianNoteEnter";
        callback.__raw = ''
          function(ev)
            vim.keymap.set("v", "<C-l>", "<cmd>Obsidian link<cr>", {
              buffer = ev.buf,
            })

            vim.keymap.set("v", "<C-n>", "<cmd>Obsidian link_new<cr>", {
              buffer = ev.buf,
            })

            vim.keymap.set("v", "<C-x>", "<cmd>Obsidian extract_note<cr>", {
              buffer = ev.buf,
            })
          end
        '';
      }
    ];
    keymaps = [
      {
        mode = "n";
        key = "<leader>nn";
        action = "<cmd>Obsidian new<CR>";
        options.desc = "[N]ew [N]ote";
      }
      {
        mode = "n";
        key = "<leader>sn";
        action = "<cmd>Obsidian search<CR>";
        options.desc = "[S]earch [N]notes";
      }
      {
        mode = "n";
        key = "<leader>st";
        action = "<cmd>Obsidian tags<CR>";
        options.desc = "[S]earch Nnote [T]ags";
      }
    ];
  };
}
