local wez = require('wezterm')
return {
    default_prog     = { 'zsh' },
    cell_width = 0.85,
    -- Performance --------------
    front_end        = "OpenGL",
    enable_wayland   = true,
    scrollback_lines = 1024,
    -- Fonts --------
    font = wez.font_with_fallback({ 
        "Iosevka Nerd Font",
        "Material Design Icons",
    }),
    dpi = 140,
    bold_brightens_ansi_colors = true,
    font_rules    = {
        {
            italic = true,
            font = wez.font("Iosevka Nerd Font", { italic = true })
        }
    },
    --font_antialias = "Subpixel",
    --font_hinting = "VerticalSubpixel",
    font_size         = 14.0,
    line_height       = 1.15,
    harfbuzz_features = { 'calt=1', 'clig=1', 'liga=1' },
    -- Bling --------
    -- color_scheme   = "followSystem",
    
    initial_rows = 20,
	initial_cols = 124,

    window_padding = {
        left = "24pt", right = "24pt",
        bottom = "24pt", top = "24pt"
    },
    default_cursor_style = "SteadyUnderline",
    enable_scroll_bar    = false,
    warn_about_missing_glyphs = false,
    -- Tabbar ---------
    enable_tab_bar               = true,
    use_fancy_tab_bar            = false,
    hide_tab_bar_if_only_one_tab = true,
    show_tab_index_in_tab_bar    = false,
    -- Miscelaneous ---------------
    window_close_confirmation = "NeverPrompt",
    inactive_pane_hsb         = { 
        saturation = 1.0, brightness = 0.8
    },
    check_for_updates = false,

    colors = {
        foreground = '#dfdddd',
        background = '#0d0d0d',
        cursor_bg = '#dfdddd',
        cursor_border = '#dfdddd',
        cursor_fg = '#272727',
        selection_fg = '#0d0d0d',
        selection_bg = '#6e95bd',
        split = '#151515',
        ansi = {
            '#1b1b1b',
            '#c14d53',
            '#56966e',
            '#dc8c61',
            '#6e95bd',
            '#a56db1',
            '#6a9f98',
            '#b7b7b7',
        },
        brights = {
            '#272727',
            '#da4b52',
            '#57a274',
            '#e1956c',
            '#6fadea',
            '#d466e9',
            '#63b4b5',
            '#a4b5b5',
        },
        tab_bar = {
            background = '#272727',
            active_tab = {
                bg_color = '#0d0d0d',
                fg_color = '#dfdddd',
            },
            inactive_tab = {
                bg_color = '#272727',
                fg_color = '#dfdddd',
            },
            inactive_tab_hover = {
                bg_color = '#1b1b1b',
                fg_color = '#dfdddd',
            },
            inactive_tab_edge = '#1b1b1b',
            new_tab = {
                bg_color = '#272727',
                fg_color = '#b7b7b7',
            },
            new_tab_hover = {
                bg_color = '#1b1b1b',
                fg_color = '#dfdddd',
            },
        }
    }
}
