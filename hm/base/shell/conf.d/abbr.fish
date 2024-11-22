function edit_file
    echo $EDITOR $argv
end
# call txt files like a program then opening them in vim
abbr -a edit_texts --position command --regex ".+\.txt" --function edit_file

# nice example
# abbr 4DIRS --set-cursor=! "$(string join \n -- 'for dir in */' 'cd $dir' '!' 'cd ..' 'end')"
