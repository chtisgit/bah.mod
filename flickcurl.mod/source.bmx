' Copyright 2008-2011 Bruce A Henderson
'
' Licensed under the Apache License, Version 2.0 (the "License");
' you may not use this file except in compliance with the License.
' You may obtain a copy of the License at
'
'     http://www.apache.org/licenses/LICENSE-2.0
'
' Unless required by applicable law or agreed to in writing, software
' distributed under the License is distributed on an "AS IS" BASIS,
' WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
' See the License for the specific language governing permissions and
' limitations under the License.
'
SuperStrict

Import BaH.Raptor
Import BRL.Blitz

Import "config/*.h"
Import "flickcurl/src/*.h"

Import "../raptor.mod/src/*.h"
Import "../libcurlssl.mod/src/include/*.h"
Import "../libxml.mod/src/*.h"

Rem
Import "src/activity-api.c"
Import "src/vsnprintf.c"
Import "src/activity.c"
Import "src/args.c"
Import "src/auth-api.c"
Import "src/blog.c"
Import "src/blogs-api.c"
Import "src/category.c"
Import "src/comments.c"
Import "src/common.c"
Import "src/config.c"
Import "src/contacts-api.c"
Import "src/contacts.c"
Import "src/context.c"
Import "src/exif.c"
Import "src/favorites-api.c"
Import "src/group.c"
Import "src/groups-api.c"
Import "src/groups-pools-api.c"
Import "src/interestingness-api.c"
Import "src/location.c"
Import "src/machinetags.c"
Import "src/machinetags-api.c"
Import "src/md5.c"
Import "src/method.c"
Import "src/people-api.c"
Import "src/perms.c"
Import "src/person.c"
Import "src/photo.c"
Import "src/photos-api.c"
Import "src/photos-comments-api.c"
Import "src/photos-geo-api.c"
Import "src/photos-licenses-api.c"
Import "src/photos-notes-api.c"
Import "src/photos-transform-api.c"
Import "src/photos-upload-api.c"
Import "src/photoset.c"
Import "src/photosets-api.c"
Import "src/photosets-comments-api.c"
Import "src/place.c"
Import "src/places-api.c"
Import "src/prefs-api.c"
Import "src/reflection-api.c"
Import "src/serializer.c"
Import "src/size.c"
Import "src/tags-api.c"
Import "src/tags.c"
Import "src/test-api.c"
Import "src/ticket.c"
Import "src/upload-api.c"
Import "src/urls-api.c"
Import "src/user_upload_status.c"
Import "src/video.c"
Import "src/shape.c"
Import "src/commons-api.c"
Import "src/institution.c"
Import "src/panda-api.c"
Import "src/config.c"
Import "src/members.c"
End Rem

Import "flickcurl/src/activity-api.c"
Import "flickcurl/src/activity.c"
Import "flickcurl/src/args.c"
Import "flickcurl/src/auth-api.c"
Import "flickcurl/src/blog.c"
Import "flickcurl/src/blogs-api.c"
Import "flickcurl/src/category.c"
Import "flickcurl/src/collection.c"
Import "flickcurl/src/collections-api.c"
Import "flickcurl/src/comments.c"
Import "flickcurl/src/common.c"
Import "flickcurl/src/commons-api.c"
Import "flickcurl/src/config.c"
Import "flickcurl/src/contacts-api.c"
Import "flickcurl/src/contacts.c"
Import "flickcurl/src/context.c"
Import "flickcurl/src/exif.c"
Import "flickcurl/src/favorites-api.c"
Import "flickcurl/src/galleries-api.c"
Import "flickcurl/src/gallery.c"
Import "flickcurl/src/group.c"
Import "flickcurl/src/groups-api.c"
Import "flickcurl/src/groups-members-api.c"
Import "flickcurl/src/groups-pools-api.c"
Import "flickcurl/src/institution.c"
Import "flickcurl/src/interestingness-api.c"
Import "flickcurl/src/location.c"
Import "flickcurl/src/machinetags-api.c"
Import "flickcurl/src/machinetags.c"
Import "flickcurl/src/md5.c"
Import "flickcurl/src/members.c"
Import "flickcurl/src/method.c"
Import "flickcurl/src/note.c"
Import "flickcurl/src/panda-api.c"
Import "flickcurl/src/people-api.c"
Import "flickcurl/src/perms.c"
Import "flickcurl/src/person.c"
Import "flickcurl/src/photo.c"
Import "flickcurl/src/photos-api.c"
Import "flickcurl/src/photos-comments-api.c"
Import "flickcurl/src/photos-geo-api.c"
Import "flickcurl/src/photos-licenses-api.c"
Import "flickcurl/src/photos-notes-api.c"
Import "flickcurl/src/photos-people-api.c"
Import "flickcurl/src/photos-transform-api.c"
Import "flickcurl/src/photos-upload-api.c"
Import "flickcurl/src/photoset.c"
Import "flickcurl/src/photosets-api.c"
Import "flickcurl/src/photosets-comments-api.c"
Import "flickcurl/src/place.c"
Import "flickcurl/src/places-api.c"
Import "flickcurl/src/prefs-api.c"
Import "flickcurl/src/reflection-api.c"
Import "flickcurl/src/serializer.c"
Import "flickcurl/src/shape.c"
Import "flickcurl/src/size.c"
Import "flickcurl/src/stat.c"
Import "flickcurl/src/stats-api.c"
Import "flickcurl/src/tags-api.c"
Import "flickcurl/src/tags.c"
Import "flickcurl/src/test-api.c"
Import "flickcurl/src/ticket.c"
Import "flickcurl/src/upload-api.c"
Import "flickcurl/src/urls-api.c"
Import "flickcurl/src/user_upload_status.c"
Import "flickcurl/src/video.c"
Import "flickcurl/src/vsnprintf.c"

Import "glue.cpp"


