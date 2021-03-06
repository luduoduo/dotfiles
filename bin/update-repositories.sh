#!/bin/sh
#
# ===================================================================
#       Title: update-repositories.sh
#   Copyright: Kevin Funk <kevin@kfunk.org>
#     License: CC BY 2.0
# ===================================================================
#
# Purpose:
#   This will update all repositories in $PWD/* (non-recursive)
#   If $PWD already contains a repository, only this is updated.
#   Recursive-mode can be simulated easily, see script support.
#
# Usage:
#   $ cd path/to/src/ # should contain various repositories in sub-folders
#   $ update-repositories.sh # will automatically update all repositories
#
# Supported repository types:
#   * CVS
#   * SVN
#   * Git
#   * Git-SVN
#   * HG
#
# Script support
#   Additional script support for the following files: $PWD/*/.update-procedure.sh
#   These scripts (if existant) will be called instead of using the VCS tools.
#
#   Example script (placed in Qt5 repository):
#     $ cat qt5/.update-procedure.sh
#
#     #!/bin/sh
#     ./qtrepotools/bin/qt5_tool -p
#
#   Example script if you want to do recursive updating:
#     $ cat other-sources/.update-procedure.sh
#
#     #!/bin/sh
#     update-repositories.sh # invoke calling script again
#

# update current working directory
update_pwd()
{
    # call update script if there is any
    test -x ".update-procedure.sh" &&
        echo "Calling $PWD/.update-procedure.sh" &&
        $PWD/.update-procedure.sh &&
        echo "Done." &&
        return 0

    # update repository depending on VCS used
    test -x ".svn" &&
        svn up && return 0
    test -x ".git" &&
        if git svn info 2> /dev/null; then
            # Git-SVN fetch
            git svn fetch
            return 0
        else
            # also fetch objects in submodules if there are any
            if test -f .gitmodules; then
                git submodule foreach --recursive git fetch --all
            fi

            # Default Git fetch
            git fetch --all
            return 0
        fi
    test -x "CVS" &&
        cvs up && return 0
    test -x ".hg" &&
        hg update && return 0

    return 1
}

# check each subdirectory for version control systems
check_subdirectories()
{
    local INITIAL_PWD="$PWD"
    for i in ./*/; do
        echo "*** Checking ${i} ***"

        # enter directory, update, reset cwd
        cd "$i"
        update_pwd
        cd "$INITIAL_PWD"
    done
}

main()
{
    local INITIAL_PWD="$PWD"

    echo "*** Fetching new objects from repositories ***"

    # if current working directory has no repository, check subdirectories
    echo "*** Checking subdirectories ***"
    check_subdirectories

    # be sure to return to old CWD
    cd "$INITIAL_PWD"

    echo "*** Done fetching new objects ***"
}

# start of main routine
main
