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


# Updating the schema version

DELETE FROM meta WHERE meta_key="schema_version";
INSERT INTO meta (meta_key,meta_value) VALUES ("schema_version",40);

# add table structure for table 'conservation_score'

CREATE TABLE conservation_score (
  genomic_align_block_id bigint unsigned not null,
  window_size            smallint unsigned not null,
  position	         int unsigned not null,
  observed_score         blob,
  expected_score         blob,
  diff_score             blob,

  KEY (genomic_align_block_id, window_size)
) MAX_ROWS = 15000000 AVG_ROW_LENGTH = 841 COLLATE=latin1_swedish_ci;
