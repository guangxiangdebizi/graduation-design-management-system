USE graduation_design;

UPDATE dictionary_items
   SET item_label='终稿/结题材料'
 WHERE dict_type='document_type' AND item_code='final';

UPDATE system_configs
   SET description='终稿/结题材料上传开关'
 WHERE config_key='switch.upload_final';
