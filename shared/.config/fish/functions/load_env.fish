function load_env --description 'Load environment variables from .env file' --argument env_file
    if test -f "$env_file"
        for line in (cat "$env_file" | grep -v '^#' | grep -v '^$')
            set clean_line (string replace -r '^export\s+' '' $line)
            set -gx (string split -m 1 = $clean_line)
        end
    else
        echo "load_env: file not found: $env_file" >&2
        return 1
    end
end
