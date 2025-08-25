<<<<<<< HEAD
﻿

 
$Resources = get-azresource -name wolffsynadlsacct   | Select -Property *
 
$Resource_tag =  $($Resources) | select Name, Tags, resourcegroupname, ID , subscription

$Resource_tag.tags

$Resource_tag.Tags.keys
$Resource_tag.Tags.Values






            $Resource_tag.tags.GetEnumerator() | ForEach-Object {

                  Write-Output "$($_.key)   = $($_.Value)" 
                      if($($_.key) -eq 'Purpose')
                      {

                        Write-host -ForegroundColor Green " Purpose = $($_.value)"
                        $purpose= $($_.value)
                      }
                  }
 
   $purpose

=======
﻿

 
$Resources = get-azresource -name wolffsynadlsacct   | Select -Property *
 
$Resource_tag =  $($Resources) | select Name, Tags, resourcegroupname, ID , subscription

$Resource_tag.tags

$Resource_tag.Tags.keys
$Resource_tag.Tags.Values






            $Resource_tag.tags.GetEnumerator() | ForEach-Object {

                  Write-Output "$($_.key)   = $($_.Value)" 
                      if($($_.key) -eq 'Purpose')
                      {

                        Write-host -ForegroundColor Green " Purpose = $($_.value)"
                        $purpose= $($_.value)
                      }
                  }
 
   $purpose

>>>>>>> d52ce840e8be3c3b3ed9cc2c09f1fb868b28362c
