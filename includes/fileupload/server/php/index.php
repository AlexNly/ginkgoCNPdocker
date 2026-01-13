<?php
/*
 * jQuery File Upload Plugin PHP Example 5.14
 * https://github.com/blueimp/jQuery-File-Upload
 *
 * Copyright 2010, Sebastian Tschan
 * https://blueimp.net
 *
 * Licensed under the MIT license:
 * http://www.opensource.org/licenses/MIT
 */

// ini_set('post_max_size','4294967296');
// ini_set('upload_max_filesize','4294967296');


set_time_limit(0);
error_reporting(E_ALL | E_STRICT);

// Set session user_id from POST/GET if not already set
session_start();
if (isset($_REQUEST['user_id']) && !empty($_REQUEST['user_id'])) {
    $_SESSION['user_id'] = $_REQUEST['user_id'];
}

require('UploadHandler.php');

#echo ini_get("upload_tmp_dir") . "|";
#ini_set('upload_tmp_dir','/tmp/web-uploads/2');#mnt/data/ginkgo/test/uploads/
#echo sys_get_temp_dir() . "---";
$upload_handler = new UploadHandler();

#phpinfo();
