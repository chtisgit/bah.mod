' Copyright (c) 2009-2018 Bruce A Henderson
'
'  The contents of this file are subject to the Mozilla Public License
'  Version 1.1 (the "License"); you may not use this file except in
'  compliance with the License. You may obtain a copy of the License at
'  http://www.mozilla.org/MPL/
'  
'  Software distributed under the License is distributed on an "AS IS"
'  basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
'  License for the specific language governing rights and limitations
'  under the License.
'  
'  The Original Code is BaH.TagLib.
'  
'  The Initial Developer of the Original Code is Bruce A Henderson.
'
SuperStrict

Import BRL.Map
Import BRL.LinkedList
Import BRL.Bank

Import "source.bmx"

Extern

	Function bmx_taglib_fileref_create:Byte Ptr(filename:String, readAudioProperties:Int, audioPropertiesStyle:Int)
	Function bmx_taglib_fileref_tag:Byte Ptr(handle:Byte Ptr)
	Function bmx_taglib_fileref_audioproperties:Byte Ptr(handle:Byte Ptr)
	Function bmx_taglib_fileref_delete(handle:Byte Ptr)
	Function bmx_taglib_fileref_save:Int(handle:Byte Ptr)
	Function bmx_taglib_fileref_isnull:Int(handle:Byte Ptr)

	Function bmx_taglib_tag_title:String(handle:Byte Ptr)
	Function bmx_taglib_tag_artist:String(handle:Byte Ptr)
	Function bmx_taglib_tag_album:String(handle:Byte Ptr)
	Function bmx_taglib_tag_comment:String(handle:Byte Ptr)
	Function bmx_taglib_tag_genre:String(handle:Byte Ptr)
	Function bmx_taglib_tag_year:Int(handle:Byte Ptr)
	Function bmx_taglib_tag_track:Int(handle:Byte Ptr)
	Function bmx_taglib_tag_settitle(handle:Byte Ptr, value:String)
	Function bmx_taglib_tag_setartist(handle:Byte Ptr, value:String)
	Function bmx_taglib_tag_setalbum(handle:Byte Ptr, value:String)
	Function bmx_taglib_tag_setcomment(handle:Byte Ptr, value:String)
	Function bmx_taglib_tag_setgenre(handle:Byte Ptr, value:String)
	Function bmx_taglib_tag_setyear(handle:Byte Ptr, value:Int)
	Function bmx_taglib_tag_settrack(handle:Byte Ptr, value:Int)
	Function bmx_taglib_tag_isempty:Int(handle:Byte Ptr)
	Function bmx_taglib_tag_properties:Byte Ptr(handle:Byte Ptr)

	Function bmx_taglib_audoproperties_length:Int(handle:Byte Ptr)
	Function bmx_taglib_audoproperties_bitrate:Int(handle:Byte Ptr)
	Function bmx_taglib_audoproperties_samplerate:Int(handle:Byte Ptr)
	Function bmx_taglib_audoproperties_channels:Int(handle:Byte Ptr)

	Function bmx_taglib_mpegproperties_version:Int(handle:Byte Ptr)
	Function bmx_taglib_mpegproperties_layer:Int(handle:Byte Ptr)
	Function bmx_taglib_mpegproperties_protectionenabled:Int(handle:Byte Ptr)
	Function bmx_taglib_mpegproperties_channelmode:Int(handle:Byte Ptr)
	Function bmx_taglib_mpegproperties_iscopyrighted:Int(handle:Byte Ptr)
	Function bmx_taglib_mpegproperties_isoriginal:Int(handle:Byte Ptr)
	
	Function bmx_taglib_file_readonly:Int(handle:Byte Ptr)
	Function bmx_taglib_file_properties:Byte Ptr(handle:Byte Ptr)

	Function bmx_taglib_mpegfile_create:Byte Ptr(filename:String, readProperties:Int, propertiesStyle:Int)
	Function bmx_taglib_mpegfile_free(handle:Byte Ptr)
	Function bmx_taglib_mpegfile_audioproperties:Byte Ptr(handle:Byte Ptr)
	Function bmx_taglib_mpegfile_save:Int(handle:Byte Ptr)
	Function bmx_taglib_mpegfile_savetags:Int(handle:Byte Ptr, tags:Int, stripOthers:Int)
	Function bmx_taglib_mpegfile_id3v2tag:Byte Ptr(handle:Byte Ptr, _create:Int)
	Function bmx_taglib_mpegfile_id3v1tag:Byte Ptr(handle:Byte Ptr , _create:Int)
	Function bmx_taglib_mpegfile_apetag:Byte Ptr(handle:Byte Ptr , _create:Int)
	Function bmx_taglib_mpegfile_strip:Int(handle:Byte Ptr, tags:Int, freeMemory:Int)
	Function bmx_taglib_mpegfile_firstframeoffset:Int(handle:Byte Ptr)
	Function bmx_taglib_mpegfile_nextframeoffset:Int(handle:Byte Ptr, position:Int)
	Function bmx_taglib_mpegfile_previousframeoffset:Int(handle:Byte Ptr, position:Int)
	Function bmx_taglib_mpegfile_lastframeoffset:Int(handle:Byte Ptr)
	Function bmx_taglib_mpegfile_isopen:Int(handle:Byte Ptr)
	Function bmx_taglib_mpegfile_isvalid:Int(handle:Byte Ptr)
	Function bmx_taglib_mpegfile_clear(handle:Byte Ptr)
	Function bmx_taglib_mpegfile_length:Int(handle:Byte Ptr)

	Function bmx_taglib_id3v2header_majorversion:Int(handle:Byte Ptr)
	Function bmx_taglib_id3v2header_revisionnumber:Int(handle:Byte Ptr)
	Function bmx_taglib_id3v2header_unsynchronisation:Int(handle:Byte Ptr)
	Function bmx_taglib_id3v2header_extendedheader:Int(handle:Byte Ptr)
	Function bmx_taglib_id3v2header_experimentalindicator:Int(handle:Byte Ptr)
	Function bmx_taglib_id3v2header_footerpresent:Int(handle:Byte Ptr)
	Function bmx_taglib_id3v2header_tagsize:Int(handle:Byte Ptr)
	Function bmx_taglib_id3v2header_completetagsize:Int(handle:Byte Ptr)
	Function bmx_taglib_id3v2header_settagsize(handle:Byte Ptr, size:Int)

	Function bmx_taglib_id3v2tag_header:Object(handle:Byte Ptr)
	Function bmx_taglib_id3v2tag_framelist:Byte Ptr(handle:Byte Ptr)

	Function bmx_taglib_id3v2framelist_free(handle:Byte Ptr)
	Function bmx_taglib_id3v2framelist_nextframe:Object(handle:Byte Ptr)
	Function bmx_taglib_id3v2framelist_reset(handle:Byte Ptr)
	Function bmx_taglib_id3v2framelist_frame:Object(handle:Byte Ptr, index:Int)
	Function bmx_taglib_id3v2framelist_isempty:Int(handle:Byte Ptr)
	Function bmx_taglib_id3v2framelist_size:Int(handle:Byte Ptr)

	Function bmx_taglib_file_isreadable:Int(file:String)
	Function bmx_taglib_file_iswritable:Int(name:String)

	Function bmx_taglib_oggvorbisfile_create:Byte Ptr(filename:String, readProperties:Int, propertiesStyle:Int)
	Function bmx_taglib_oggvorbisfile_free(handle:Byte Ptr)
	Function bmx_taglib_oggvorbisfile_audioproperties:Byte Ptr(handle:Byte Ptr)
	Function bmx_taglib_oggvorbisfile_save:Int(handle:Byte Ptr)
	Function bmx_taglib_oggvorbisfile_tag:Byte Ptr(handle:Byte Ptr)

	Function bmx_taglib_oggxiphcomment_fieldlistmap:Byte Ptr(handle:Byte Ptr)
	Function bmx_taglib_oggxiphcomment_fieldcount:Int(handle:Byte Ptr)
	Function bmx_taglib_oggxiphcomment_vendorid:String(handle:Byte Ptr)
	Function bmx_taglib_oggxiphcomment_addfield(handle:Byte Ptr, key:String, value:String, _replace:Int)
	Function bmx_taglib_oggxiphcomment_removefield(handle:Byte Ptr, key:String, value:String)
	Function bmx_taglib_oggxiphcomment_contains:Int(handle:Byte Ptr, key:String)

	Function bmx_taglib_oggfieldlistmap_field:String[](handle:Byte Ptr, key:String)
	Function bmx_taglib_oggfieldlistmap_isempty:Int(handle:Byte Ptr)
	Function bmx_taglib_oggfieldlistmap_size:Int(handle:Byte Ptr)
	Function bmx_taglib_oggfieldlistmap_reset(handle:Byte Ptr)
	Function bmx_taglib_oggfieldlistmap_free(handle:Byte Ptr)
	Function bmx_taglib_oggfieldlistmap_nextfield:String[](handle:Byte Ptr)
	
	Function bmx_taglib_vorbisproperties_vorbisversion:Int(handle:Byte Ptr)
	Function bmx_taglib_vorbisproperties_bitratemaximum:Int(handle:Byte Ptr)
	Function bmx_taglib_vorbisproperties_bitratenominal:Int(handle:Byte Ptr)
	Function bmx_taglib_vorbisproperties_bitrateminimum:Int(handle:Byte Ptr)

	Function bmx_taglib_bytevector_tostring:String(handle:Byte Ptr)
	Function bmx_taglib_bytevector_free(handle:Byte Ptr)
	Function bmx_taglib_bytevector_data:Byte Ptr(handle:Byte Ptr)
	Function bmx_taglib_bytevector_clear(handle:Byte Ptr)
	Function bmx_taglib_bytevector_size:Int(handle:Byte Ptr)
	Function bmx_taglib_bytevector_isempty:Int(handle:Byte Ptr)

	Function bmx_taglib_id3v2frame_tostring:String(handle:Byte Ptr)
	Function bmx_taglib_id3v2frame_frameid:Byte Ptr(handle:Byte Ptr)
	Function bmx_taglib_id3v2frame_size:Int(handle:Byte Ptr)

	Function bmx_taglib_id3v2attachedpictureframe_textencoding:Int(handle:Byte Ptr)
	Function bmx_taglib_id3v2attachedpictureframe_mimetype:String(handle:Byte Ptr)
	Function bmx_taglib_id3v2attachedpictureframe_imagetype:Int(handle:Byte Ptr)
	Function bmx_taglib_id3v2attachedpictureframe_description:String(handle:Byte Ptr)
	Function bmx_taglib_id3v2attachedpictureframe_picture:Byte Ptr(handle:Byte Ptr)

	Function bmx_taglib_id3v2textidentificationframe_settext(handle:Byte Ptr, Text:String)
	Function bmx_taglib_id3v2textidentificationframe_settextlist(handle:Byte Ptr, Text:String[])
	Function bmx_taglib_id3v2textidentificationframe_tostring:String(handle:Byte Ptr)
	Function bmx_taglib_id3v2textidentificationframe_textencoding:Int(handle:Byte Ptr)
	Function bmx_taglib_id3v2textidentificationframe_settextencoding(handle:Byte Ptr, encoding:Int)
	Function bmx_taglib_id3v2textidentificationframe_fieldlist:String[](handle:Byte Ptr)

	Function bmx_taglib_id3v2urllinkframe_url:String(handle:Byte Ptr)
	Function bmx_taglib_id3v2urllinkframe_seturl(handle:Byte Ptr, Text:String)
	Function bmx_taglib_id3v2urllinkframe_settext(handle:Byte Ptr, Text:String)
	Function bmx_taglib_id3v2urllinkframe_tostring:String(handle:Byte Ptr)

	Function bmx_taglib_id3v2commentsframe_tostring:String(handle:Byte Ptr)
	Function bmx_taglib_id3v2commentsframe_description:String(handle:Byte Ptr)
	Function bmx_taglib_id3v2commentsframe_text:String(handle:Byte Ptr)
	Function bmx_taglib_id3v2commentsframe_textencoding:Int(handle:Byte Ptr)
	Function bmx_taglib_id3v2commentsframe_settextencoding(handle:Byte Ptr, encoding:Int)
	Function bmx_taglib_id3v2commentsframe_setdescription(handle:Byte Ptr, description:String)
	Function bmx_taglib_id3v2commentsframe_settext(handle:Byte Ptr, Text:String)

	Function bmx_taglib_mp4file_create:Byte Ptr(filename:String, readProperties:Int, propertiesStyle:Int)
	Function bmx_taglib_mp4file_audioproperties:Byte Ptr(handle:Byte Ptr)
	Function bmx_taglib_mp4file_save:Int(handle:Byte Ptr)
	Function bmx_taglib_mp4file_tag:Byte Ptr(handle:Byte Ptr)
	Function bmx_taglib_mp4file_free(handle:Byte Ptr)
	Function bmx_taglib_mp4file_isopen:Int(handle:Byte Ptr)
	Function bmx_taglib_mp4file_isvalid:Int(handle:Byte Ptr)
	Function bmx_taglib_mp4file_clear(handle:Byte Ptr)
	Function bmx_taglib_mp4file_length:Int(handle:Byte Ptr)

	Function bmx_taglib_mp4tag_itemlist:Byte Ptr(handle:Byte Ptr)

	Function bmx_taglib_mp4itemlistmap_item:Object(handle:Byte Ptr, key:String)
	Function bmx_taglib_mp4itemlistmap_isempty:Int(handle:Byte Ptr)
	Function bmx_taglib_mp4itemlistmap_size:Int(handle:Byte Ptr)
	Function bmx_taglib_mp4itemlistmap_reset(handle:Byte Ptr)
	Function bmx_taglib_mp4itemlistmap_free(handle:Byte Ptr)
	Function bmx_taglib_mp4itemlistmap_nextitem:Object(handle:Byte Ptr)

	Function bmx_taglib_mp4coverartlist_coverart:Object(handle:Byte Ptr, index:Int)
	Function bmx_taglib_mp4coverartlist_isempty:Int(handle:Byte Ptr)
	Function bmx_taglib_mp4coverartlist_size:Int(handle:Byte Ptr)
	Function bmx_taglib_mp4coverartlist_reset(handle:Byte Ptr)
	Function bmx_taglib_mp4coverartlist_free(handle:Byte Ptr)
	Function bmx_taglib_mp4coverartlist_nextitem:Object(handle:Byte Ptr)
	
	Function bmx_taglib_mp4coverart_format:Int(handle:Byte Ptr)
	Function bmx_taglib_mp4coverart_data:Byte Ptr(handle:Byte Ptr)

	Function bmx_taglib_mp4item_coverartlist:Byte Ptr(handle:Byte Ptr)
	Function bmx_taglib_mp4item_isvalid:Int(handle:Byte Ptr)
	Function bmx_taglib_mp4item_toint:Int(handle:Byte Ptr)
	Function bmx_taglib_mp4item_tobool:Int(handle:Byte Ptr)
	Function bmx_taglib_mp4item_tointpair(handle:Byte Ptr, _first:Int Ptr, _second:Int Ptr)
	Function bmx_taglib_mp4item_tostrings:String[](handle:Byte Ptr)

	Function bmx_taglib_mp4properties_bitspersample:Int(handle:Byte Ptr)

	Function bmx_taglib_propertymap_contains:Int(handle:Byte Ptr, key:String)
	Function bmx_taglib_propertymap_values:String[](handle:Byte Ptr, key:String)
	Function bmx_taglib_propertymap_free(handle:Byte Ptr)

	Function bmx_taglib_apetag_checkkey:Int(key:String)

	Function bmx_taglib_apetag_itemlist:Byte Ptr(handle:Byte Ptr)
	
	Function bmx_taglib_apeitemlistmap_item:Object(handle:Byte Ptr, key:String)
	Function bmx_taglib_apeitemlistmap_isempty:Int(handle:Byte Ptr)
	Function bmx_taglib_apeitemlistmap_size:Int(handle:Byte Ptr)
	Function bmx_taglib_apeitemlistmap_reset(handle:Byte Ptr)
	Function bmx_taglib_apeitemlistmap_free(handle:Byte Ptr)
	Function bmx_taglib_apeitemlistmap_nextitem:Object(handle:Byte Ptr)

	Function bmx_taglib_apeitem_key:String(handle:Byte Ptr)
	Function bmx_taglib_apeitem_size:Int(handle:Byte Ptr)
	Function bmx_taglib_apeitem_values:String[](handle:Byte Ptr)
	Function bmx_taglib_apeitem_isreadonly:Int(handle:Byte Ptr)
	Function bmx_taglib_apeitem_isempty:Int(handle:Byte Ptr)

	Function bmx_taglib_flacfile_create:Byte Ptr(filename:String, readProperties:Int, propertiesStyle:Int)
	Function bmx_taglib_flacfile_free(handle:Byte Ptr)
	Function bmx_taglib_flacfile_audioproperties:Byte Ptr(handle:Byte Ptr)
	Function bmx_taglib_flacfile_save:Int(handle:Byte Ptr)
	Function bmx_taglib_flacfile_id3v2tag:Byte Ptr(handle:Byte Ptr, _create:Int)
	Function bmx_taglib_flacfile_id3v1tag:Byte Ptr(handle:Byte Ptr, _create:Int)
	Function bmx_taglib_flacfile_picturelist:Byte Ptr(handle:Byte Ptr)
	Function bmx_taglib_flacfile_removepictures(handle:Byte Ptr)
	Function bmx_taglib_flacfile_addpicture(handle:Byte Ptr, picture:Byte Ptr)
	Function bmx_taglib_flacfile_xiphcomment:Byte Ptr(handle:Byte Ptr, _create:Int)

	Function bmx_taglib_flacproperties_samplewidth:Int(handle:Byte Ptr)
	Function bmx_taglib_flacproperties_sampleframes(handle:Byte Ptr, frames:Long Ptr)
	Function bmx_taglib_flacproperties_signature:Byte Ptr(handle:Byte Ptr)

	Function bmx_taglib_flacpicturelist_picture:Object(handle:Byte Ptr, index:Int)
	Function bmx_taglib_flacpicturelist_isempty:Int(handle:Byte Ptr)
	Function bmx_taglib_flacpicturelist_size:Int(handle:Byte Ptr)
	Function bmx_taglib_flacpicturelist_reset(handle:Byte Ptr)
	Function bmx_taglib_flacpicturelist_free(handle:Byte Ptr)
	Function bmx_taglib_flacpicturelist_nextitem:Object(handle:Byte Ptr)

	Function bmx_taglib_flacpicture_colordepth:Int(handle:Byte Ptr)
	Function bmx_taglib_flacpicture_data:Byte Ptr(handle:Byte Ptr)
	Function bmx_taglib_flacpicture_description:String(handle:Byte Ptr)
	Function bmx_taglib_flacpicture_height:Int(handle:Byte Ptr)
	Function bmx_taglib_flacpicture_mimetype:String(handle:Byte Ptr)
	Function bmx_taglib_flacpicture_numcolors:Int(handle:Byte Ptr)
	Function bmx_taglib_flacpicture_setcolordepth(handle:Byte Ptr, depth:Int)
	Function bmx_taglib_flacpicture_setdata(handle:Byte Ptr, data:Byte Ptr)
	Function bmx_taglib_flacpicture_setdescription(handle:Byte Ptr, desc:String)
	Function bmx_taglib_flacpicture_setheight(handle:Byte Ptr, height:Int)
	Function bmx_taglib_flacpicture_setmimetype(handle:Byte Ptr, mimeType:String)
	Function bmx_taglib_flacpicture_setnumcolors(handle:Byte Ptr, numColors:Int)
	Function bmx_taglib_flacpicture_settype(handle:Byte Ptr, pictureType:Int)
	Function bmx_taglib_flacpicture_setwidth(handle:Byte Ptr, w:Int)
	Function bmx_taglib_flacpicture_picturetype:Int(handle:Byte Ptr)
	Function bmx_taglib_flacpicture_width:Int(handle:Byte Ptr)

End Extern

Rem
bbdoc: IS08859-1, or Latin1 encoding. 8 bit characters.
End Rem
Const STRINGTYPE_LATIN1:Int = 0
Rem
bbdoc: UTF16 with a byte order mark. 16 bit characters. 
End Rem
Const STRINGTYPE_UTF16:Int = 1
Rem
bbdoc: UTF16 big endian. 16 bit characters.
about: This is the encoding used internally by TagLib. 
End Rem
Const STRINGTYPE_UTF16BE:Int = 2
Rem
bbdoc: UTF8 encoding.
about: Characters are usually 8 bits but can be up to 32. 
End Rem
Const STRINGTYPE_UTF8:Int = 3
Rem
bbdoc: UTF16 little endian. 16 bit characters. 
End Rem
Const STRINGTYPE_UTF16LE:Int = 4

