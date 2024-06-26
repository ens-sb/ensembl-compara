-- See the NOTICE file distributed with this work for additional information
-- regarding copyright ownership.
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--      http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

# patch_105_106_b.sql
#
# Title: Widen clusterset_id field in gene_tree_root.
#
# Description:
#   Widen clusterset_id field in gene_tree_root to allow new wheat cultivars prefix.

ALTER TABLE gene_tree_root MODIFY COLUMN clusterset_id VARCHAR(50) NOT NULL DEFAULT 'default';

# Patch identifier
INSERT INTO meta (species_id, meta_key, meta_value)
  VALUES (NULL, 'patch', 'patch_105_106_b.sql|clusterset_id_varchar50');
