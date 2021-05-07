SEMGREP_GO_REPO="https://github.com/dgryski/semgrep-go"
SEMGREP_GO_FOLDER="semgrep-go"

semgrep_get_policies() {
  PHOLDER_QUOTES="#placeholder-quotes#"
  PHOLDER_SLASH="#placeholder-slash#"

  if [ -d "$SEMGREP_GO_FOLDER" ]; then rm -Rf $SEMGREP_GO_FOLDER; fi
  git clone $SEMGREP_GO_REPO;

  # substitute \ and \" symbols by placeholder so yq doesn't strip them
  sed 's/\\"/'"$PHOLDER_QUOTES"'/g' .semgrep.yml | sed 's/\\/'"$PHOLDER_SLASH"'/g' > .semgrep.yml.fixed
  mv .semgrep.yml{.fixed,}

  if [[ -f .semgrep.yml.bak ]]
  then
    # substitute \ and \" symbols by placeholder so yq doesn't strip them
    sed 's/\\"/'"$PHOLDER_QUOTES"'/g' .semgrep.yml.bak | sed 's/\\/'"$PHOLDER_SLASH"'/g' > .semgrep.yml.fixed
    yq eval-all 'select(fileIndex == 0).rules + select(fileIndex == 1).rules' .semgrep.yml.bak .semgrep.yml |\
          yq eval '{"rules": .}' - > .semgrep.yml.fixed
    mv .semgrep.yml{.fixed,}
    rm .semgrep.yml.bak
  fi

  find "$SEMGREP_GO_FOLDER" -iname '*.yaml' -or -iname '*.yml' | while read entry
  do
      # substitute \ and \" symbols by placeholder so yq doesn't strip them
      cat .semgrep.yml | sed 's/\\"/'"$PHOLDER_QUOTES"'/g' | sed 's/\\/'"$PHOLDER_SLASH"'/g' > .semgrep.yml.fixed
      mv .semgrep.yml{.fixed,}

      yq eval-all 'select(fileIndex == 0).rules + select(fileIndex == 1).rules' $entry .semgrep.yml |\
        yq eval '{"rules": .}' - > .semgrep.yml.fixed
      mv .semgrep.yml{.fixed,}
  done

  # restore \ and \" symbols from placeholder
  cat .semgrep.yml | sed 's/'"$PHOLDER_QUOTES"'/\\"/g' | sed 's/'"$PHOLDER_SLASH"'/\\\\/g' > .semgrep.yml.fixed
  mv .semgrep.yml{.fixed,}

  rm -rf semgrep-go
}
