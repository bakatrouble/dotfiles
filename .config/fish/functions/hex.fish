function hex --wraps="xxd -p | tr -d '\\n'" --description "alias hex=xxd -p | tr -d '\\n'"
  xxd -p | tr -d '\n' $argv
        
end
