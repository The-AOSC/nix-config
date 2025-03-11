{...}: {
  programs.fish.interactiveShellInit = ''
    set --universal fish_color_autosuggestion brblack
    set --universal fish_color_cancel -r
    set --universal fish_color_command blue
    set --universal fish_color_comment red
    set --universal fish_color_cwd green
    set --universal fish_color_cwd_root red
    set --universal fish_color_end green
    set --universal fish_color_error brred
    set --universal fish_color_escape brcyan
    set --universal fish_color_history_current --bold
    set --universal fish_color_host normal
    set --universal fish_color_host_remote yellow
    set --universal fish_color_normal normal
    set --universal fish_color_operator brcyan
    set --universal fish_color_param cyan
    set --universal fish_color_quote yellow
    set --universal fish_color_redirection cyan --bold
    set --universal fish_color_search_match bryellow --background=brblack
    set --universal fish_color_selection white --bold --background=brblack
    set --universal fish_color_status red
    set --universal fish_color_user brgreen
    set --universal fish_color_valid_path --underline
    set --universal fish_pager_color_completion normal
    set --universal fish_pager_color_description yellow -i
    set --universal fish_pager_color_prefix normal --bold --underline
    set --universal fish_pager_color_progress brwhite --background=cyan
    set --universal fish_pager_color_selected_background -r
  '';
}
