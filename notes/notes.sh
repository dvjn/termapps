#!/bin/bash

notes() {

  local DEFAULT_NOTES_DIR="$TERMAPPS_INSTALL/saved/notes"
  local DEFAULT_NOTES_EXTENSION="md"
  local DEFAULT_NOTES_EDITOR="nano"
  local DEFAULT_NOTES_READER="less"
  
  local NOTES_DIR=${NOTES_DIR-$DEFAULT_NOTES_DIR}
  local NOTES_EXTENSION=${NOTES_EXTENSION-$DEFAULT_NOTES_EXTENSION}
  local NOTES_EDITOR=${NOTES_EDITOR-${EDITOR-$DEFAULT_NOTES_EDITOR}}
  local NOTES_READER=${NOTES_READER-$DEFAULT_NOTES_READER}
 
  local HELP_STR="usage:
    notes <command> [nested notes ...]
  
commands:
    list      List all the notes and subnotes.
    read      Read a note in \$NOTES_READER.
    create    Create a new note.
    edit      Create(if not present) and edit a note in \$EDITOR.
    remove    Remove specified note.
    help      View this help.
  
environment:
    NOTES_DIR         Directory to store the notes. Defaults to \$TERMAPPS_INSTALL/saved/notes.
    NOTES_EXTENSION   Format of saved notes. Defaults to $DEFAULT_NOTES_EXTENSION.
    NOTES_EDITOR      Editor to edit the notes. Defaults to \$EDITOR if set, else $DEFAULT_NOTES_EDITOR.
    NOTES_READER      Reader for reading notes. Defaults to $DEFAULT_NOTES_READER.
"
  
  [ ! -d "$NOTES_DIR" ] && mkdir -p "$NOTES_DIR"
  
  local cmd=${1-"help"}
  [[ $# -ne 0 ]] && shift
  
  join_by() { local IFS="$1"; shift; echo "$*"; }
  
  local NOTE_PATH="$NOTES_DIR/$(join_by / $@)/note.$NOTES_EXTENSION"
  local NOTE_DIR="$(dirname "$NOTE_PATH")"
  
  case $cmd in
    read)
      $NOTES_READER "$NOTE_PATH"
      ;;
    create)
      [ "$NOTE_DIR" = "$NOTES_DIR" ] && echo "Specify the note name." && return
      [ ! -d "$NOTE_DIR" ] && mkdir -p "$NOTE_DIR"
      touch "$NOTE_PATH"
      ;;
    edit)
      [ "$NOTE_DIR" = "$NOTES_DIR" ] && echo "Specify the note name." && return
      [ ! -d "$NOTE_DIR" ] && mkdir -p "$NOTE_DIR"
      $NOTES_EDITOR "$NOTE_PATH"
      ;;
    remove)
      [ "$NOTE_DIR" = "$NOTES_DIR" ] && echo "Specify the note name." && return
      rm "$NOTE_PATH" 2> /dev/null
      find "$NOTES_DIR" -mindepth 1 -type d -empty -delete
      ;;
    list)
      find "$NOTE_DIR" -name "*.$NOTES_EXTENSION" | sed -e "s+^$NOTES_DIR/++" -e "s+/note.$NOTES_EXTENSION$++" -e "s+/+ +g" | sort 
      ;;
    help)
      echo "$HELP_STR"
      ;;
    *)
      echo "Invalid argument $cmd" >&2
      return
      ;;
  esac
}
