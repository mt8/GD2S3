  #aws
  export AWS_ACCESS_KEY_ID=YOUR_AWS_ACCESS_KEY_ID
  export AWS_SECRET_ACCESS_KEY=YOUR_AWS_SECRET_ACCESS_KEY
  AWS_DEFAULT_REGION=YOUR_AWS_DEFAULT_REGION
  S3_BUCKET_NAME=s3://YOUR_S3_BUCKET_NAME
  aws="/usr/local/bin/aws --region=${AWS_DEFAULT_REGION}"

  #dir
  GIT_REPO_DIR='/PATH/TO/YOUR/GIT/REPOSITORY/DIR'
  OUT_PUT_DIR='/PATH/TO/YOUR/WORK/DIR'
  WOKR_DIR='work'
  OUT_PUT_NAME='www' #set your s3 bucket root dir.

  #base commit id
  BASE_COMMIT='HEAD'
  
  ## Check AWS CLI
  which aws || exit 2

  command_usage() {
    echo "Usage: git_deploy_to_s3.sh [arg...]"
    echo ''
    echo "Commands:"
    echo "    sync      [git COMMIT ID]"
    echo "    sync-all  GIT_REPO_DIR sync to Target S3 BUCKET (All Files)"
  }

  sync_clean() {
    ${aws} s3 sync  ${GIT_REPO_DIR}/ ${S3_BUCKET_NAME}/ --exclude ".git/*" --exclude ".gitignore" --exclude ".DS_Store" --delete
  }

  case "$1" in

    #
    # sync
    #
    'sync' )
    if [[ "$2" = '--help' ]]; then
      command_usage
    else

      if [[ "$2" ]]; then
        #echo 'TEST sync'
        #echo "ID : $2"

        #create work dir
        mkdir -p ${OUT_PUT_DIR}/${WOKR_DIR}

        #move to git repo
        cd ${GIT_REPO_DIR}

        #archive diff
        git archive --format=zip --prefix=${OUT_PUT_NAME}/ HEAD `git diff --diff-filter=D --name-only ${BASE_COMMIT} $2` -o ${OUT_PUT_DIR}/${WOKR_DIR}/${OUT_PUT_NAME}.zip

        #unzip
        unzip -o -q ${OUT_PUT_DIR}/${WOKR_DIR}/${OUT_PUT_NAME}.zip -d ${OUT_PUT_DIR}/${WOKR_DIR}

        #s3 sync
        ${aws} s3 sync ${OUT_PUT_DIR}/${WOKR_DIR}/${OUT_PUT_NAME}/ ${S3_BUCKET_NAME}/ --exclude ".git/*" --exclude ".gitignore" --exclude ".DS_Store"

        #clean
        rm -rf ${OUT_PUT_DIR}/${WOKR_DIR}
        #sync_clean

      else

        echo ''
        echo 'necessary to set [git COMMIT ID]'
        echo 'ex : [COMMAND] sync [git COMMIT ID]'
        echo ''

      fi

    fi
    ;;

    #
    # sync-all
    #
    'sync-all' )
    if [[ "$2" = '--help' ]]; then
      command_usage
    else
      ${aws} s3 sync  ${GIT_REPO_DIR}/ ${S3_BUCKET_NAME}/ --exclude ".git/*" --exclude ".gitignore" --exclude ".DS_Store" --delete
    fi
    ;;

  esac
