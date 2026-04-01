# ╔══════════════════════════════════════════════════════════════╗
# ║                  space — fish shell function                ║
# ║         Disk usage + top folders, beautifully              ║
# ╚══════════════════════════════════════════════════════════════╝
# Place in ~/.config/fish/functions/space.fish

function space --description "Show disk usage and top biggest folders"

    # ── Colors ────────────────────────────────────────────────
    set red      '\e[38;5;203m'
    set green    '\e[38;5;114m'
    set yellow   '\e[38;5;221m'
    set blue     '\e[38;5;75m'
    set magenta  '\e[38;5;183m'
    set cyan     '\e[38;5;87m'
    set orange   '\e[38;5;215m'
    set white    '\e[38;5;253m'
    set bold     '\e[1m'
    set dim      '\e[2m'
    set reset    '\e[0m'

    # ── Helper: bar ───────────────────────────────────────────
    function __bar --argument-names pct
        set filled (math "round($pct / 5)")
        set empty (math "20 - $filled")
        set bar ""

        for i in (seq 1 $filled)
            set bar "$bar█"
        end

        for i in (seq 1 $empty)
            set bar "$bar░"
        end

        if test $pct -ge 85
            echo -e "$red$bar$reset"
        else if test $pct -ge 60
            echo -e "$yellow$bar$reset"
        else
            echo -e "$green$bar$reset"
        end
    end

    # ── Header ────────────────────────────────────────────────
    echo ""
    echo -e "$bold$cyan  ╔═══════════════════════════════════════╗$reset"
    echo -e "$bold$cyan  ║          DISK PEEK 󰋊                  ║$reset"
    echo -e "$bold$cyan  ╚═══════════════════════════════════════╝$reset"
    echo ""

    # ── Total Storage Summary ─────────────────────────────────
    set total_used_bytes 0
    set total_size_bytes 0

    df -B1 --output=source,used,size -x tmpfs -x devtmpfs -x efivarfs -x fuseblk 2>/dev/null \
    | tail -n +2 \
    | grep -v '/run/media' \
    | sort -u -k1,1 \
    | while read -l source used size
        set total_used_bytes (math "$total_used_bytes + $used")
        set total_size_bytes (math "$total_size_bytes + $size")
    end

    if test $total_size_bytes -gt 0
        set total_pct (math "round($total_used_bytes * 100 / $total_size_bytes)")
        set used_gb (printf "%.1f" (math "$total_used_bytes / 1073741824"))
        set size_gb (printf "%.1f" (math "$total_size_bytes / 1073741824"))
        set bar (__bar $total_pct)

        if test $total_pct -ge 85
            set pct_color $red
        else if test $total_pct -ge 60
            set pct_color $yellow
        else
            set pct_color $green
        end

        echo -e "$bold$white  󰋊  TOTAL STORAGE$reset"
        echo -e "$dim$white  ─────────────────────────────────────────$reset"
        echo -e "  $bar  $bold$white"$used_gb"G$reset / $white"$size_gb"G$reset  $bold$pct_color"$total_pct"%$reset"
        echo ""
    end

    # ── Disk usage per mount ──────────────────────────────────
    echo -e "$bold$white  󰆼  DISK USAGE$reset"
    echo -e "$dim$white  ─────────────────────────────────────────$reset"

    df -h --output=target,used,size,pcent -x tmpfs -x devtmpfs -x efivarfs -x fuseblk 2>/dev/null \
    | tail -n +2 \
    | grep -v '/run/media' \
    | while read -l mount used size pct

        set pct_num (string replace '%' '' $pct)
        set bar (__bar $pct_num)

        if test $pct_num -ge 85
            set pct_color "$red$bold"
        else if test $pct_num -ge 60
            set pct_color $yellow
        else
            set pct_color $green
        end

        # Use printf only for padding, then echo -e to avoid % being
        # interpreted as a format specifier in printf
        set mount_fmt (printf "%-20s" "$mount")
        set used_fmt (printf "%6s" "$used")
        set size_fmt (printf "%-6s" "$size")
        echo -e "  $blue$mount_fmt$reset  $bar  $white$used_fmt$reset / $white$size_fmt$reset  $pct_color"$pct_num"%$reset"
    end

    echo ""

    # ── Top 5 biggest folders in /home ────────────────────────
    echo -e "$bold$white  󱂵  TOP 5 IN HOME (/home)$reset"
    echo -e "$dim$white  ─────────────────────────────────────────$reset"

    set rank 1
    du -sh /home/*/ 2>/dev/null \
    | sort -rh \
    | head -5 \
    | while read -l size path

        set folder (basename $path)

        switch $rank
            case 1
                set medal "$yellow 1$reset"
                set color $yellow
            case 2
                set medal "$white 2$reset"
                set color $white
            case 3
                set medal "$orange 3$reset"
                set color $orange
            case '*'
                set medal "$dim$white  $rank$reset"
                set color $white
        end

        printf "  %b  $color%-30s$reset  $magenta%s$reset\n" \
            $medal $folder $size

        set rank (math $rank + 1)
    end

    echo ""
    echo -e "$dim$white  ───────────────── space 󰋊 ──────────────────$reset"
    echo ""

    # cleanup inner function
    functions --erase __bar
end
