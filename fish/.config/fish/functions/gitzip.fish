function gitzip --wraps='git archive HEAD -o .zip' --wraps='git archive HEAD -o Spoolman-Companion.zip' --description 'alias gitzip=git archive HEAD -o Spoolman-Companion.zip'
  git archive HEAD -o Spoolman-Companion.zip $argv
        
end
