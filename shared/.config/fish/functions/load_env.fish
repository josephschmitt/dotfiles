function load_env --description 'Load environment variables from .env file' --argument env_file
    if test -f "$env_file"
        while read -l line
            # Skip empty lines and comments
            if string match -qr '^[[:space:]]*$|^#' -- $line
                continue
            end

            # Remove 'export ' prefix if present
            set clean_line (string replace -r '^export\s+' '' -- $line)

            # Split and export
            set -gx (string split -m 1 = -- $clean_line)
        end < "$env_file"
    else
        echo "load_env: file not found: $env_file" >&2
        return 1
    end
end
