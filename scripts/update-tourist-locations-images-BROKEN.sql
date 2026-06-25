-- SQL Script to Update Tourist Locations Firebase Storage Images
-- This script changes firebase_storage_images column from TEXT to JSON
-- and updates all 133 tourist locations with their firebase storage image links
-- Data source: specs/tourist_attractions.json

-- Begin transaction to ensure atomicity
BEGIN;

-- Step 1: Add a temporary column with JSON datatype
ALTER TABLE tourist_locations ADD COLUMN firebase_storage_images_json JSON;

-- Step 2: Update all locations with their firebase storage images
-- The following updates map each location by place_name to its images array

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F1-Ganpatipule%20Beach%20%26%20Ganpati%20Mandir%2FScreenshot%202025-12-15%20105022.png?alt=media&token=d43b0073-4f02-4677-b9d4-f0473a58ea9b", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F1-Ganpatipule%20Beach%20%26%20Ganpati%20Mandir%2FScreenshot%202025-12-15%20105031.png?alt=media&token=8c532feb-a409-432d-9a5f-1f0df70c2325", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F1-Ganpatipule%20Beach%20%26%20Ganpati%20Mandir%2FScreenshot%202025-12-15%20105120.png?alt=media&token=fd201e18-4b4c-4de9-9d27-6b013ce3ac73", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F1-Ganpatipule%20Beach%20%26%20Ganpati%20Mandir%2FScreenshot%202025-12-15%20105201.png?alt=media&token=6cc3b989-e30c-4bab-a8c7-3b3f1ff006b7", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F1-Ganpatipule%20Beach%20%26%20Ganpati%20Mandir%2FScreenshot%202025-12-15%20105352.png?alt=media&token=44291c9c-b2bc-4c7d-b284-e26d743b532c"]'::JSON 
WHERE place_name = 'Ganpatipule Beach & Ganpati Mandir';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F2-Ratnadurg%20Fort%20(Bhagwati%20Fort)%2FScreenshot%202025-12-15%20105502.png?alt=media&token=bcbd1294-976b-4fae-ae45-e9ef7ca8d29c", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F2-Ratnadurg%20Fort%20(Bhagwati%20Fort)%2FScreenshot%202025-12-15%20105518.png?alt=media&token=378e5ad2-945b-4ea5-b8c5-a7563cba12da", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F2-Ratnadurg%20Fort%20(Bhagwati%20Fort)%2FScreenshot%202025-12-15%20105543.png?alt=media&token=779eabf7-9a96-4a4b-a515-3b64520681ed", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F2-Ratnadurg%20Fort%20(Bhagwati%20Fort)%2FScreenshot%202025-12-15%20105617.png?alt=media&token=65eb9979-0b66-46b8-a344-f5f83d3ef016", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F2-Ratnadurg%20Fort%20(Bhagwati%20Fort)%2FScreenshot%202025-12-15%20105856.png?alt=media&token=5272ee21-addf-48bc-adab-6868a5bdfbab"]'::JSON 
WHERE place_name = 'Ratnadurg Fort (Bhagwati Fort)';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F3-Thiba%20Palace%2FScreenshot%202025-12-15%20105731.png?alt=media&token=5bc2b43f-4bf3-45d3-bf1b-6a5f477ddb04", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F3-Thiba%20Palace%2FScreenshot%202025-12-15%20110100.png?alt=media&token=d6ec672d-3bcc-4638-afb4-c4af9fc6db2d", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F3-Thiba%20Palace%2FScreenshot%202025-12-15%20110116.png?alt=media&token=24b376ce-d160-4de8-a510-9ae70829e30c", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F3-Thiba%20Palace%2FScreenshot%202025-12-15%20110310.png?alt=media&token=8aa492c1-ead4-4057-ae9d-17c4bbf32c23", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F3-Thiba%20Palace%2FScreenshot%202025-12-15%20110431.png?alt=media&token=9135fb0f-d23f-49be-bdd8-838d170fcf81"]'::JSON 
WHERE place_name = 'Thiba Palace';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F4-Mandavi%20Beach%20(Black%20Sand%20Beach)%2FScreenshot%202025-12-15%20110554.png?alt=media&token=9adc038f-5a6e-4e9e-8e22-af654f2cb08c", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F4-Mandavi%20Beach%20(Black%20Sand%20Beach)%2FScreenshot%202025-12-15%20110622.png?alt=media&token=72de0d75-70c1-43cf-892f-660ba28196d2", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F4-Mandavi%20Beach%20(Black%20Sand%20Beach)%2FScreenshot%202025-12-15%20110644.png?alt=media&token=5592f067-a73a-4b20-9afc-df47517fc837", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F4-Mandavi%20Beach%20(Black%20Sand%20Beach)%2FScreenshot%202025-12-15%20110711.png?alt=media&token=7994f284-09d5-47aa-9c0e-aa4bd3e60ab5"]'::JSON 
WHERE place_name = 'Mandavi Beach (Black Sand Beach)';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F5-Jaigad%20Fort%2FScreenshot%202025-12-15%20111915.png?alt=media&token=0df488f6-95b9-4247-8e87-7cff1c5456e9", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F5-Jaigad%20Fort%2FScreenshot%202025-12-15%20111957.png?alt=media&token=49f0517e-5e62-433a-ad43-2ea62f48074d", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F5-Jaigad%20Fort%2FScreenshot%202025-12-15%20112018.png?alt=media&token=48d53788-ae60-482d-bc26-2ebafa9f649a", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F5-Jaigad%20Fort%2FScreenshot%202025-12-15%20112039.png?alt=media&token=51ebb506-cbd9-4cae-be05-9570e819a3cb", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F5-Jaigad%20Fort%2FScreenshot%202025-12-15%20112207.png?alt=media&token=8feb889a-a7e7-4557-a4c4-22523d0fce5f", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F5-Jaigad%20Fort%2FScreenshot%202025-12-15%20112246.png?alt=media&token=b6d89970-45b0-43da-8fb7-4878e4705742", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F5-Jaigad%20Fort%2FScreenshot%202025-12-15%20112323.png?alt=media&token=5aa8bc40-b641-4feb-909d-d364e7f986e7"]'::JSON 
WHERE place_name = 'Jaigad Fort';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F6-Jaigad%20Lighthouse%2FScreenshot%202025-12-15%20112440.png?alt=media&token=81e0e41e-5687-44ef-9b86-921a6b5f78c6", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F6-Jaigad%20Lighthouse%2FScreenshot%202025-12-15%20112501.png?alt=media&token=ccf17c56-9904-4505-a2bd-f7595b92cc52", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F6-Jaigad%20Lighthouse%2FScreenshot%202025-12-15%20112526.png?alt=media&token=92e7d09d-1728-4bf9-9da5-03e48af178da", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F6-Jaigad%20Lighthouse%2FScreenshot%202025-12-15%20112540.png?alt=media&token=ce10e66e-5928-44ab-93a2-c47bc104ebd4"]'::JSON 
WHERE place_name = 'Jaigad Lighthouse';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F7-Aare%20Ware%20Beach%20(Twin%20Beaches)%2FScreenshot%202025-12-15%20112709.png?alt=media&token=38ab4893-0d7e-4456-8a9d-cc8b29026078", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F7-Aare%20Ware%20Beach%20(Twin%20Beaches)%2FScreenshot%202025-12-15%20112737.png?alt=media&token=72fe726e-54f5-444a-bef5-0c1b6f3e8d92", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F7-Aare%20Ware%20Beach%20(Twin%20Beaches)%2FScreenshot%202025-12-15%20112800.png?alt=media&token=f4aeaa7c-391a-4ead-98b1-ac3a4aac47a9", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F7-Aare%20Ware%20Beach%20(Twin%20Beaches)%2FScreenshot%202025-12-15%20112857.png?alt=media&token=a635639d-eb9b-49d4-97fe-26bcfc03bd50"]'::JSON 
WHERE place_name = 'Aare Ware Beach (Twin Beaches)';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F8-Kasheli%20Beach%2FScreenshot%202025-12-15%20113157.png?alt=media&token=ad7561d2-52f7-4663-84d3-930c793cd892", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F8-Kasheli%20Beach%2FScreenshot%202025-12-15%20113217.png?alt=media&token=bdb45abe-1ccc-434a-bf49-1debbc37774c", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F8-Kasheli%20Beach%2FScreenshot%202025-12-15%20113246.png?alt=media&token=541becfe-f19c-4c15-9ead-7eda7cbd8666", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F8-Kasheli%20Beach%2FScreenshot%202025-12-15%20113301.png?alt=media&token=da453ace-486e-4397-b44a-9fd11ba3dec1"]'::JSON 
WHERE place_name = 'Kasheli Beach';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F9-Marine%20Museum%20(Aquarium)%2FScreenshot%202025-12-15%20113425.png?alt=media&token=cbb2a249-00a2-4303-bd82-8599670ddcea", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F9-Marine%20Museum%20(Aquarium)%2FScreenshot%202025-12-15%20114046.png?alt=media&token=5ece0a21-956b-4632-9cdc-2de82e2ba9c2"]'::JSON 
WHERE place_name = 'Marine Museum (Aquarium)';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F10-Bhatye%20Beach%2FScreenshot%202025-12-15%20114136.png?alt=media&token=80857a3c-27e0-48ba-b08a-26686fa15c1c", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F10-Bhatye%20Beach%2FScreenshot%202025-12-15%20114150.png?alt=media&token=3aa8a89e-b233-4779-802b-38b1c0d1d4c8", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F10-Bhatye%20Beach%2FScreenshot%202025-12-15%20114204.png?alt=media&token=6961501d-cb32-4653-85fb-f2b3b53fe377"]'::JSON 
WHERE place_name = 'Bhatye Beach';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F11-Arey-Ware%20Ghat%20Scenic%20Road%2FScreenshot%202025-12-15%20114429.png?alt=media&token=53a2cbdd-91aa-4285-ae0e-6c7150ff677e", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F11-Arey-Ware%20Ghat%20Scenic%20Road%2FScreenshot%202025-12-15%20114445.png?alt=media&token=8c6240ed-e95e-4654-b620-da0feb52499f", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F11-Arey-Ware%20Ghat%20Scenic%20Road%2FScreenshot%202025-12-15%20114514.png?alt=media&token=e099c566-ef7f-4071-82d4-12187d489ec1"]'::JSON 
WHERE place_name = 'Arey-Ware Ghat Scenic Road';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F12-Purnagad%20Fort%2FScreenshot%202025-12-15%20115857.png?alt=media&token=576179b0-b379-4f7a-9eba-8e79a0eb3aa8", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F12-Purnagad%20Fort%2FScreenshot%202025-12-15%20115918.png?alt=media&token=06db8bf8-360f-45ed-8cfc-00d806c138f1", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F12-Purnagad%20Fort%2FScreenshot%202025-12-15%20115940.png?alt=media&token=ebfbf549-f912-4e0d-acd7-82483a71e7e4"]'::JSON 
WHERE place_name = 'Purnagad Fort';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F13-Malgund%20Village%20%E2%80%93%20Birthplace%20of%20Keshavsut%2FScreenshot%202025-12-15%20120139.png?alt=media&token=8ce46fa4-6786-4f87-8d37-9cf535c7613e", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F13-Malgund%20Village%20%E2%80%93%20Birthplace%20of%20Keshavsut%2FScreenshot%202025-12-15%20120158.png?alt=media&token=0bac628d-11a3-4e50-baf2-624f31a1c675", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F13-Malgund%20Village%20%E2%80%93%20Birthplace%20of%20Keshavsut%2FScreenshot%202025-12-15%20120224.png?alt=media&token=f7d09ebe-0500-4e66-b13a-1ddc5fb5d092"]'::JSON 
WHERE place_name = 'Malgund Village – Birthplace of Keshavsut';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F14-Kalbadevi%20Temple%20%26%20Beach%2FScreenshot%202025-12-15%20120449.png?alt=media&token=cafa8d58-ddef-4896-a94e-930a633b5745", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F14-Kalbadevi%20Temple%20%26%20Beach%2FScreenshot%202025-12-15%20120514.png?alt=media&token=1ad2b95f-eef4-4e46-a17a-b1d6f8c048c9"]'::JSON 
WHERE place_name = 'Kalbadevi Temple & Beach';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F15-Pokharbav%20Ganpati%20Mandir%2FScreenshot%202025-12-15%20202756.png?alt=media&token=db3b2a7a-1bf8-4f43-9fc8-c17d903d8007", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F15-Pokharbav%20Ganpati%20Mandir%2FScreenshot%202025-12-15%20202924.png?alt=media&token=77de1856-9d48-4612-9dcf-558cbdcf26d9"]'::JSON 
WHERE place_name = 'Pokharbav Ganpati Mandir';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F16-Karhateshwar%20Temple%2FScreenshot%202025-12-16%20001630.png?alt=media&token=294f620f-b4a9-4e35-9226-6055b9a55beb", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F16-Karhateshwar%20Temple%2FScreenshot%202025-12-16%20001646.png?alt=media&token=f966605e-06f2-4535-b38f-35e6166890da", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F16-Karhateshwar%20Temple%2FScreenshot%202025-12-16%20001750.png?alt=media&token=a86b733a-243f-4e0b-8c04-c987dc2673e8"]'::JSON 
WHERE place_name = 'Karhateshwar Temple';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F17-Panval%20Waterfall%2FScreenshot%202025-12-16%20005454.png?alt=media&token=498fd0e1-f853-497f-b118-1ef073386fcd", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F17-Panval%20Waterfall%2FScreenshot%202025-12-16%20005504.png?alt=media&token=962147a4-90b1-48ba-b587-408d1647c399", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F17-Panval%20Waterfall%2FScreenshot%202025-12-16%20005524.png?alt=media&token=907093b7-ff8b-4059-b0f9-ad29f2742633"]'::JSON 
WHERE place_name = 'Panval Waterfall';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F18-Mirya%20Beach%2FScreenshot%202025-12-16%20014714.png?alt=media&token=5274af6b-33e2-43c4-8d1d-4eed1d68e642", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F18-Mirya%20Beach%2FScreenshot%202025-12-16%20014724.png?alt=media&token=bfa7b506-fb33-4a6c-867c-2a75d0021cf2", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F18-Mirya%20Beach%2FScreenshot%202025-12-16%20014734.png?alt=media&token=d40f3a74-4e82-4be1-ae16-fe59ce1e5614", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F18-Mirya%20Beach%2FScreenshot%202025-12-16%20014744.png?alt=media&token=4555e3a4-89a5-4f63-bf5a-0746edbccf0b"]'::JSON 
WHERE place_name = 'Mirya Beach';

UPDATE tourist_locations 
SET firebase_storage_images_json = '[]'::JSON 
WHERE place_name = 'Avachitwadi village, Malgund';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F20-Hanuman%20Kundi%20(Waterfall%20Point)%2FScreenshot%202025-12-16%20022503.png?alt=media&token=7edf10aa-bdbd-4fcb-b093-3f78f8a47f03", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F20-Hanuman%20Kundi%20(Waterfall%20Point)%2FScreenshot%202025-12-16%20022514.png?alt=media&token=7c667c19-cbec-40a8-b07f-331eaf3f9b29", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F20-Hanuman%20Kundi%20(Waterfall%20Point)%2FScreenshot%202025-12-16%20022524.png?alt=media&token=983e1386-492d-4b78-8ec5-f5af48705864"]'::JSON 
WHERE place_name = 'Hanuman Kundi (Waterfall Point)';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F21-Jay%20Vinayak%20Temple%2FScreenshot%202025-12-16%20022655.png?alt=media&token=17b5ecc7-676c-43b0-b7a0-2e449ab74349", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F21-Jay%20Vinayak%20Temple%2FScreenshot%202025-12-16%20022704.png?alt=media&token=d89c02be-5c66-4c2c-8c90-b1eb9ff788c3", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F21-Jay%20Vinayak%20Temple%2FScreenshot%202025-12-16%20022716.png?alt=media&token=287c04e8-5b0b-48ab-9e3d-0a3f557bfff2", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F21-Jay%20Vinayak%20Temple%2FScreenshot%202025-12-16%20022733.png?alt=media&token=022777ff-820c-4858-a795-c30eb0f81752"]'::JSON 
WHERE place_name = 'Jay Vinayak Temple';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F22-Phansavle%20Bridge%2FScreenshot%202025-12-16%20024755.png?alt=media&token=87e20329-df82-4f69-8312-0206040482f6", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F22-Phansavle%20Bridge%2FScreenshot%202025-12-16%20024812.png?alt=media&token=ea59e392-6c29-4427-8871-ab93202a42e0", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F22-Phansavle%20Bridge%2FScreenshot%202025-12-16%20024851.png?alt=media&token=a0b8859c-0181-49e0-8123-746c76eea4d2"]'::JSON 
WHERE place_name = 'Phansavle Bridge';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F23-Kanakaditya%20Temple%20(Sun%20Temple)%2FScreenshot%202025-12-16%20024928.png?alt=media&token=5be5f1f0-2d23-45d7-af9f-5161328f8bea", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F23-Kanakaditya%20Temple%20(Sun%20Temple)%2FScreenshot%202025-12-16%20024937.png?alt=media&token=576f1907-06f7-43cd-8322-0fffe4f33c66", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F23-Kanakaditya%20Temple%20(Sun%20Temple)%2FScreenshot%202025-12-16%20024947.png?alt=media&token=4f8021ad-81a6-42e5-b239-fb1ebc55d871", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F23-Kanakaditya%20Temple%20(Sun%20Temple)%2FScreenshot%202025-12-16%20025038.png?alt=media&token=bc6eabdf-469c-4132-83ec-f53895520294"]'::JSON 
WHERE place_name = 'Kanakaditya Temple (Sun Temple)';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F24-Devgad%20Beach%20%2B%20Fort%2FScreenshot%202025-12-16%20025119.png?alt=media&token=26afd25f-c8d4-45bf-b1d5-1c3ff653c3e1", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F24-Devgad%20Beach%20%2B%20Fort%2FScreenshot%202025-12-16%20025129.png?alt=media&token=acd13479-7efc-4bc9-a55b-a7d60c07cd77", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F24-Devgad%20Beach%20%2B%20Fort%2FScreenshot%202025-12-16%20025140.png?alt=media&token=491bcbd1-be06-4f6a-927c-8b1f986980a9", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F24-Devgad%20Beach%20%2B%20Fort%2FScreenshot%202025-12-16%20025149.png?alt=media&token=60531cff-2aca-4638-8b6d-088ef83a21d5"]'::JSON 
WHERE place_name = 'Devgad Beach + Fort';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F25-Kunkeshwar%20Temple%20%26%20Beach%2FScreenshot%202025-12-16%20025251.png?alt=media&token=f38d1aa6-5df1-4201-baab-1120916339e7", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F25-Kunkeshwar%20Temple%20%26%20Beach%2FScreenshot%202025-12-16%20025303.png?alt=media&token=0d432fa1-8ecd-4e03-b2f7-5906a86e4542", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F25-Kunkeshwar%20Temple%20%26%20Beach%2FScreenshot%202025-12-16%20025314.png?alt=media&token=35fbbd4a-47fd-4f48-9d1b-54aa47c5da16", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F25-Kunkeshwar%20Temple%20%26%20Beach%2FScreenshot%202025-12-16%20025327.png?alt=media&token=c4b0cb53-3153-4784-98e7-810f9bce52c9"]'::JSON 
WHERE place_name = 'Kunkeshwar Temple & Beach';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F26-Velas%20Beach%20(Turtle%20Festival)%2FScreenshot%202025-12-16%20025518.png?alt=media&token=700fa7dc-ec17-488d-8fc2-a8acd322eb14", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F26-Velas%20Beach%20(Turtle%20Festival)%2FScreenshot%202025-12-16%20025532.png?alt=media&token=5de9efd9-3083-4664-9732-42a7ac1774a9", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F26-Velas%20Beach%20(Turtle%20Festival)%2FScreenshot%202025-12-16%20025550.png?alt=media&token=678187bd-2b49-40e2-b4a5-0efd02735b22", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F26-Velas%20Beach%20(Turtle%20Festival)%2FScreenshot%202025-12-16%20025602.png?alt=media&token=e1fcdb51-2c98-41d7-a8d4-7717b85a3645"]'::JSON 
WHERE place_name = 'Velas Beach (Turtle Festival)';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F27-Anjarle%20Beach%20%26%20Kadyavarcha%20Ganpati%2FScreenshot%202025-12-16%20025646.png?alt=media&token=a6ee6a5b-e1ed-45bf-b818-92d69c754ebd", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F27-Anjarle%20Beach%20%26%20Kadyavarcha%20Ganpati%2FScreenshot%202025-12-16%20025655.png?alt=media&token=35fc713a-ebb2-4a6d-a28f-ae4e18aa5e43", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F27-Anjarle%20Beach%20%26%20Kadyavarcha%20Ganpati%2FScreenshot%202025-12-16%20025704.png?alt=media&token=76884e03-5755-4e2e-8b81-fc4841e9d2fa", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F27-Anjarle%20Beach%20%26%20Kadyavarcha%20Ganpati%2FScreenshot%202025-12-16%20025716.png?alt=media&token=4cf47ebd-1321-4ef0-96b6-0b6d34fa2d8d", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F27-Anjarle%20Beach%20%26%20Kadyavarcha%20Ganpati%2FScreenshot%202025-12-16%20025726.png?alt=media&token=f3761ba4-fdb7-42e1-ad32-26c0fb94b327"]'::JSON 
WHERE place_name = 'Anjarle Beach & Kadyavarcha Ganpati';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F28-Murud%20Beach%2FScreenshot%202025-12-16%20025809.png?alt=media&token=26d75452-68c2-4a30-90d7-7d0d1aea21a3", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F28-Murud%20Beach%2FScreenshot%202025-12-16%20025838.png?alt=media&token=25973651-dc24-41ce-9292-8c194cc3c0d2", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F28-Murud%20Beach%2FScreenshot%202025-12-16%20025901.png?alt=media&token=6505badf-9346-4365-aca3-15cf3b9e5660"]'::JSON 
WHERE place_name = 'Murud Beach';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F29-Harnai%20Port%20%26%20Fish%20Auction%20Market%2FScreenshot%202025-12-16%20025941.png?alt=media&token=69587ece-e739-4a07-a92d-00ab2e37b57b", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F29-Harnai%20Port%20%26%20Fish%20Auction%20Market%2FScreenshot%202025-12-16%20025952.png?alt=media&token=2f6e569e-eaad-4687-941e-8575c8d3fa7f", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F29-Harnai%20Port%20%26%20Fish%20Auction%20Market%2FScreenshot%202025-12-16%20030005.png?alt=media&token=ede3302d-9d62-4421-bf41-a432d52a967b"]'::JSON 
WHERE place_name = 'Harnai Port & Fish Auction Market';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F30-Suvarnadurg%20Fort%20(Sea%20Fort)%2FScreenshot%202025-12-16%20030203.png?alt=media&token=0961a199-1b83-4624-b9a8-8964d43ba7b4", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F30-Suvarnadurg%20Fort%20(Sea%20Fort)%2FScreenshot%202025-12-16%20030213.png?alt=media&token=cbd8ad2f-e5e3-42d1-ad5e-b8aed903da76", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F30-Suvarnadurg%20Fort%20(Sea%20Fort)%2FScreenshot%202025-12-16%20030223.png?alt=media&token=fbbb0d3b-46b7-404c-a1d1-6292b65fc947", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F30-Suvarnadurg%20Fort%20(Sea%20Fort)%2FScreenshot%202025-12-16%20030235.png?alt=media&token=a8e01698-7795-4db4-a3c0-26399c016010"]'::JSON 
WHERE place_name = 'Suvarnadurg Fort (Sea Fort)';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F31-Panhalekaji%20Caves%2FScreenshot%202025-12-16%20030323.png?alt=media&token=fbc332fa-7bf4-4790-a279-7783fdf2f3f1", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F31-Panhalekaji%20Caves%2FScreenshot%202025-12-16%20030332.png?alt=media&token=63225de0-c3b1-4a17-bb43-75405d81a444", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F31-Panhalekaji%20Caves%2FScreenshot%202025-12-16%20030342.png?alt=media&token=129abd0c-8aef-40dd-bdcf-c695cf55d857"]'::JSON 
WHERE place_name = 'Panhalekaji Caves';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F32-Ladghar%20Beach%2FScreenshot%202025-12-16%20030523.png?alt=media&token=759b9fda-52e6-4fc5-a139-cdda5a3e0460", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F32-Ladghar%20Beach%2FScreenshot%202025-12-16%20030530.png?alt=media&token=3054c113-9e13-47d3-a300-517e10d4996d", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F32-Ladghar%20Beach%2FScreenshot%202025-12-16%20030540.png?alt=media&token=ef954701-7781-463b-b30d-451b88c015a9", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F32-Ladghar%20Beach%2FScreenshot%202025-12-16%20030552.png?alt=media&token=3cbf9e99-3a59-491b-ad58-418bcd7ab3b7"]'::JSON 
WHERE place_name = 'Ladghar Beach';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F33-Kolthare%20Beach%2FScreenshot%202025-12-16%20030644.png?alt=media&token=c6d250af-945a-4f88-952c-800e52261830", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F33-Kolthare%20Beach%2FScreenshot%202025-12-16%20030653.png?alt=media&token=c90f67a2-049f-460e-a9d6-2d044a533515", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F33-Kolthare%20Beach%2FScreenshot%202025-12-16%20030701.png?alt=media&token=c6b2c00e-081a-4400-ac36-37dfc465fd03"]'::JSON 
WHERE place_name = 'Kolthare Beach';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F34-Karde%20Beach%2FScreenshot%202025-12-16%20030739.png?alt=media&token=9df32cc3-dde5-4bac-99ee-ddef2c365728", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F34-Karde%20Beach%2FScreenshot%202025-12-16%20030746.png?alt=media&token=a29c1409-5d58-4c9a-a5fd-ac958445cf22", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F34-Karde%20Beach%2FScreenshot%202025-12-16%20030755.png?alt=media&token=365a47f9-2d8b-47b3-a635-679468ea60ab"]'::JSON 
WHERE place_name = 'Karde Beach';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F35-Dabhol%20Port%20%26%20Chandika%20Devi%20Cave%20Temple%2FScreenshot%202025-12-16%20030839.png?alt=media&token=e2b93d71-242e-4427-aa43-c0bca013ae37", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F35-Dabhol%20Port%20%26%20Chandika%20Devi%20Cave%20Temple%2FScreenshot%202025-12-16%20030852.png?alt=media&token=8571e4c2-72e4-4f83-a269-52354bdadd1b", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F35-Dabhol%20Port%20%26%20Chandika%20Devi%20Cave%20Temple%2FScreenshot%202025-12-16%20030902.png?alt=media&token=f716294a-0851-42cf-bdac-638b4679eed1", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F35-Dabhol%20Port%20%26%20Chandika%20Devi%20Cave%20Temple%2FScreenshot%202025-12-16%20030930.png?alt=media&token=8a4b4a2c-9083-4776-82e5-62f8c22f13e4"]'::JSON 
WHERE place_name = 'Dabhol Port & Chandika Devi Cave Temple';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F36-Keshavraj%20Temple%2FScreenshot%202025-12-16%20031010.png?alt=media&token=c7eaaf43-e824-45cf-8027-a458a3b0223c", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F36-Keshavraj%20Temple%2FScreenshot%202025-12-16%20031017.png?alt=media&token=410f42a2-5bfd-4c27-ae2e-b0f79fa1ca03"]'::JSON 
WHERE place_name = 'Keshavraj Temple';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F37-Kanakdurg%20Fort%2FScreenshot%202025-12-16%20031114.png?alt=media&token=ae399464-f8fd-4808-aa6c-e5ffeacd2493", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F37-Kanakdurg%20Fort%2FScreenshot%202025-12-16%20031124.png?alt=media&token=24516dfd-4b28-4b60-9faf-88e2a50750de", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F37-Kanakdurg%20Fort%2FScreenshot%202025-12-16%20031133.png?alt=media&token=84cc3485-ea1e-4aa5-bea2-5f3441ce9c3b"]'::JSON 
WHERE place_name = 'Kanakdurg Fort';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F38-Fattegad%20Fort%2FScreenshot%202025-12-16%20031210.png?alt=media&token=000f5638-2fbd-464b-9bc2-c54dc8b18162", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F38-Fattegad%20Fort%2FScreenshot%202025-12-16%20031226.png?alt=media&token=ba149fdd-9d84-43fe-ae10-e1804f9dd08e"]'::JSON 
WHERE place_name = 'Fattegad Fort';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F39-Goa%20Fort%20(Gabriel%20Fort)%2FScreenshot%202025-12-16%20031258.png?alt=media&token=de9defd7-0a7e-4844-a219-cedfef173188", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F39-Goa%20Fort%20(Gabriel%20Fort)%2FScreenshot%202025-12-16%20031307.png?alt=media&token=f3a5c937-fab2-4835-a485-2c93bdb798a0", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F39-Goa%20Fort%20(Gabriel%20Fort)%2FScreenshot%202025-12-16%20031315.png?alt=media&token=526f92ad-204d-4cf8-958a-e788aed904ba"]'::JSON 
WHERE place_name = 'Goa Fort (Gabriel Fort)';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F40-Kelshi%2FScreenshot%202025-12-16%20031547.png?alt=media&token=a1a9840a-7360-43e0-b69d-2f9125bb41d9", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F40-Kelshi%2FScreenshot%202025-12-16%20031559.png?alt=media&token=dbab8a33-98d4-434d-91a1-5e57a62c333f", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F40-Kelshi%2FScreenshot%202025-12-16%20031608.png?alt=media&token=e87db9fd-88ff-40cb-a92e-b7aad9906a35"]'::JSON 
WHERE place_name = 'Kelshi';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F41-Guhagar%20Beach%2FScreenshot%202025-12-16%20031704.png?alt=media&token=efc90202-8fca-4fbb-a061-7c3d4831aec1", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F41-Guhagar%20Beach%2FScreenshot%202025-12-16%20031717.png?alt=media&token=b341bc87-98f6-4955-8254-2c9cf7222195", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F41-Guhagar%20Beach%2FScreenshot%202025-12-16%20031725.png?alt=media&token=7609ee5b-d260-4b18-ba03-b54441c99982"]'::JSON 
WHERE place_name = 'Guhagar Beach';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F42-Hedvi%20Dashabhuja%20Ganpati%20%26%20Hedvi%20Beach%2FScreenshot%202025-12-16%20031817.png?alt=media&token=94408f73-1df6-4a72-a3e4-e3b5e23ace69", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F42-Hedvi%20Dashabhuja%20Ganpati%20%26%20Hedvi%20Beach%2FScreenshot%202025-12-16%20031830.png?alt=media&token=3e90cf72-276d-4a83-b9b5-872a8dcbf7eb", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F42-Hedvi%20Dashabhuja%20Ganpati%20%26%20Hedvi%20Beach%2FScreenshot%202025-12-16%20031857.png?alt=media&token=69d70020-0525-4fc2-be0a-8834cf84ba1b"]'::JSON 
WHERE place_name = 'Hedvi Dashabhuja Ganpati & Hedvi Beach';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F43-Marleshwar%20Waterfall%20%26%20Cave%20Temple%2FScreenshot%202025-12-16%20031936.png?alt=media&token=20f2aad2-0991-4e59-a4f7-8398bcad79f9", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F43-Marleshwar%20Waterfall%20%26%20Cave%20Temple%2FScreenshot%202025-12-16%20031943.png?alt=media&token=1e44f246-c28c-461b-b467-e90be7c0b640", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F43-Marleshwar%20Waterfall%20%26%20Cave%20Temple%2FScreenshot%202025-12-16%20031952.png?alt=media&token=162d96f4-68a4-4793-8f7a-09dd32fc48db", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F43-Marleshwar%20Waterfall%20%26%20Cave%20Temple%2FScreenshot%202025-12-16%20032001.png?alt=media&token=45bb5e4e-0a5a-4b5b-84ab-2381a7f73e6f"]'::JSON 
WHERE place_name = 'Marleshwar Waterfall & Cave Temple';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F44-Tilak%20Gram%20(Birthplace%20of%20Lokmanya%20Tilak%20%E2%80%93%20near%20Ratnagiri)%2FScreenshot%202025-12-16%20032041.png?alt=media&token=4d1c3957-c077-4770-9f11-6e81e651d779", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F44-Tilak%20Gram%20(Birthplace%20of%20Lokmanya%20Tilak%20%E2%80%93%20near%20Ratnagiri)%2FScreenshot%202025-12-16%20032058.png?alt=media&token=986c3200-b048-4e1a-bc95-6e0948dba302", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F44-Tilak%20Gram%20(Birthplace%20of%20Lokmanya%20Tilak%20%E2%80%93%20near%20Ratnagiri)%2FScreenshot%202025-12-16%20032109.png?alt=media&token=aa0b4efc-6d44-4431-ae53-14a37ee13aa7"]'::JSON 
WHERE place_name = 'Tilak Gram (Birthplace of Lokmanya Tilak – near Ratnagiri)';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F45-Gopalgad%20Fort%20(Anjanvel%20Fort)%2FScreenshot%202025-12-16%20032146.png?alt=media&token=c03260fa-94bf-4012-8a42-74fd60d841a6", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F45-Gopalgad%20Fort%20(Anjanvel%20Fort)%2FScreenshot%202025-12-16%20032200.png?alt=media&token=a439dd81-2622-475b-b1d7-bd5de5a2a7ce", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F45-Gopalgad%20Fort%20(Anjanvel%20Fort)%2FScreenshot%202025-12-16%20032213.png?alt=media&token=5560596e-3027-4d6d-9cf2-406ba7ae23b7"]'::JSON 
WHERE place_name = 'Gopalgad Fort (Anjanvel Fort)';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F46-Baman%20Ghal%20(Natural%20Gorge%20at%20Hedvi)%2FScreenshot%202025-12-16%20032253.png?alt=media&token=41032b61-0d60-4a8c-9bcf-da61822841b4", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F46-Baman%20Ghal%20(Natural%20Gorge%20at%20Hedvi)%2FScreenshot%202025-12-16%20032301.png?alt=media&token=2c1ee4d9-0ce9-44f6-bbe6-759901f2cfe3"]'::JSON 
WHERE place_name = 'Baman Ghal (Natural Gorge at Hedvi)';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F47-Palshet%20Beach%20(Unexplored)%2FScreenshot%202025-12-16%20032339.png?alt=media&token=707f86fc-7872-4cbc-95cf-0539a43bf23e", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F47-Palshet%20Beach%20(Unexplored)%2FScreenshot%202025-12-16%20032348.png?alt=media&token=dee65513-4a23-42df-81c4-ab2dbfe35b97", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F47-Palshet%20Beach%20(Unexplored)%2FScreenshot%202025-12-16%20032356.png?alt=media&token=2ccb995b-a0d9-4a90-bad7-8f549263ed9a"]'::JSON 
WHERE place_name = 'Palshet Beach (Unexplored)';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F48-Velneshwar%20Beach%2FScreenshot%202025-12-16%20032506.png?alt=media&token=f3065f1a-2630-4061-81e6-592c12dcc288", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F48-Velneshwar%20Beach%2FScreenshot%202025-12-16%20032516.png?alt=media&token=87e052ce-02a5-47b1-8404-0545d5a6a712", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F48-Velneshwar%20Beach%2FScreenshot%202025-12-16%20032523.png?alt=media&token=d1d16ab3-7420-48e0-b98f-66256c02fb8a", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F48-Velneshwar%20Beach%2FScreenshot%202025-12-16%20032602.png?alt=media&token=c58b806d-6a86-479c-a5a2-22f4f7eade7b"]'::JSON 
WHERE place_name = 'Velneshwar Beach';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F49-Sapteshwar%20temple%2FScreenshot%202025-12-16%20032653.png?alt=media&token=18a5259b-ecbe-4d09-95c9-231d975674ef", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F49-Sapteshwar%20temple%2FScreenshot%202025-12-16%20032703.png?alt=media&token=5e1885f8-e4d0-403b-abbb-6ccd9676ee7b", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F49-Sapteshwar%20temple%2FScreenshot%202025-12-16%20032712.png?alt=media&token=7dbf9509-8633-4f9f-8149-f81f5d6a273d"]'::JSON 
WHERE place_name = 'Sapteshwar temple';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F50-Sangameshwar%20Kasba%20Area%2FScreenshot%202025-12-16%20032747.png?alt=media&token=0415cd3c-7819-4e91-b8a0-f1f924d0d8ad", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F50-Sangameshwar%20Kasba%20Area%2FScreenshot%202025-12-16%20032759.png?alt=media&token=e7332bde-a8d9-426b-ac8e-c7486e1c90ad", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F50-Sangameshwar%20Kasba%20Area%2FScreenshot%202025-12-16%20032816.png?alt=media&token=76891b38-a502-4c25-8005-ae8e7035bd13"]'::JSON 
WHERE place_name = 'Sangameshwar Kasba Area';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F51-Tikaleshwar%20Temple%2FScreenshot%202025-12-16%20032855.png?alt=media&token=be3b4080-c5da-4160-9bb5-f674ddf4c480", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F51-Tikaleshwar%20Temple%2FScreenshot%202025-12-16%20032903.png?alt=media&token=43385ab8-f7d0-4700-a752-dcfc8460ffc1", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F51-Tikaleshwar%20Temple%2FScreenshot%202025-12-16%20032914.png?alt=media&token=3d95c45f-f27f-492e-b24a-051e520ce761", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F51-Tikaleshwar%20Temple%2FScreenshot%202025-12-16%20032925.png?alt=media&token=f1de9ad8-7b1a-457d-a300-6fb47a8919e5"]'::JSON 
WHERE place_name = 'Tikaleshwar Temple';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F52-Konkan%20Railway%20Scenic%20Viewpoints%20(Ratnagiri%20Belt)%2FScreenshot%202025-12-16%20033033.png?alt=media&token=a9146acf-0306-40b7-acd4-d126eb544ab6", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F52-Konkan%20Railway%20Scenic%20Viewpoints%20(Ratnagiri%20Belt)%2FScreenshot%202025-12-16%20033042.png?alt=media&token=02081037-81f0-4ae9-a487-1af44522547f", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F52-Konkan%20Railway%20Scenic%20Viewpoints%20(Ratnagiri%20Belt)%2FScreenshot%202025-12-16%20033053.png?alt=media&token=40442513-ce8c-4e9d-bc24-46cdc28f41b4"]'::JSON 
WHERE place_name = 'Konkan Railway Scenic Viewpoints (Ratnagiri Belt)';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F53-Ambolgad%20Fort%2FScreenshot%202025-12-16%20033125.png?alt=media&token=8b79b214-d2ed-47d8-8457-3255945c5396", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F53-Ambolgad%20Fort%2FScreenshot%202025-12-16%20033135.png?alt=media&token=1ea3927b-6d55-4201-b2a8-2516b661cdac"]'::JSON 
WHERE place_name = 'Ambolgad Fort';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F54-Gavkhadi%20Beach%2FScreenshot%202025-12-16%20033217.png?alt=media&token=04e90e52-7057-4f51-a6c9-2255e412305d", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F54-Gavkhadi%20Beach%2FScreenshot%202025-12-16%20033226.png?alt=media&token=9c44d13d-ba49-419f-8758-a17e2e109f7d", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F54-Gavkhadi%20Beach%2FScreenshot%202025-12-16%20033234.png?alt=media&token=da5109cc-02c8-46ce-bcc5-001a118616c8"]'::JSON 
WHERE place_name = 'Gavkhadi Beach';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F55-Khorninko%20Dam%2FScreenshot%202025-12-16%20033316.png?alt=media&token=ea6e73ea-2dc7-4004-9ead-2d8bd37c5b9c", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F55-Khorninko%20Dam%2FScreenshot%202025-12-16%20033324.png?alt=media&token=06ac9131-0491-40fc-83c6-87b8815a836b", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F55-Khorninko%20Dam%2FScreenshot%202025-12-16%20033335.png?alt=media&token=70ed4d78-0a18-4af0-a377-6788b2e8abd2", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F55-Khorninko%20Dam%2FScreenshot%202025-12-16%20033346.png?alt=media&token=80db26f7-390c-41fd-9a1a-05b5c2ddd40f"]'::JSON 
WHERE place_name = 'Khorninko Dam';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F56-Wayangani%20Beach%2FScreenshot%202025-12-16%20033420.png?alt=media&token=02dfe292-4ac4-4a89-9e33-511ae62aad75", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F56-Wayangani%20Beach%2FScreenshot%202025-12-16%20033432.png?alt=media&token=34cf5c81-0a2e-4bfe-ba02-48261f99f79a", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F56-Wayangani%20Beach%2FScreenshot%202025-12-16%20033447.png?alt=media&token=d81b7b45-7055-46a9-b511-1ee8312ebe4a"]'::JSON 
WHERE place_name = 'Wayangani Beach';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F57-Talashi%20Beach%2FScreenshot%202025-12-16%20033521.png?alt=media&token=18abf310-36d5-4570-bc09-fc78fba82757", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F57-Talashi%20Beach%2FScreenshot%202025-12-16%20033530.png?alt=media&token=40232c92-332a-4fc3-b604-8abf27b72ef5", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F57-Talashi%20Beach%2FScreenshot%202025-12-16%20033557.png?alt=media&token=43f27f65-ed0c-4f8e-a084-37cd3078870d"]'::JSON 
WHERE place_name = 'Talashi Beach';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F58-Ambolgad%20Beach%2FScreenshot%202025-12-16%20033626.png?alt=media&token=7b0284db-032d-4254-8cbf-f62754489150", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F58-Ambolgad%20Beach%2FScreenshot%202025-12-16%20033632.png?alt=media&token=28e60943-fe3e-4813-a8da-f3341ce03612", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F58-Ambolgad%20Beach%2FScreenshot%202025-12-16%20033642.png?alt=media&token=c911fa80-e7e1-4b78-a32d-213707ed9b4d"]'::JSON 
WHERE place_name = 'Ambolgad Beach';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F59-Loteshwar%20temple%2FScreenshot%202025-12-16%20033721.png?alt=media&token=771b7a92-6284-4edd-bd6d-d6cf0001fd96", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F59-Loteshwar%20temple%2FScreenshot%202025-12-16%20033729.png?alt=media&token=37e00456-e900-44fd-b2c6-451720b54327", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F59-Loteshwar%20temple%2FScreenshot%202025-12-16%20033736.png?alt=media&token=6796a47c-1e4c-4316-a460-8f5848f77dee"]'::JSON 
WHERE place_name = 'Loteshwar temple';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F60-Devacha%20Dongar%2FScreenshot%202025-12-16%20033832.png?alt=media&token=fcb8caac-43bf-4c4e-a002-9935a0ee7acf", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F60-Devacha%20Dongar%2FScreenshot%202025-12-16%20033843.png?alt=media&token=1bec7f91-f85e-480f-ada2-5ab82b55f80b", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F60-Devacha%20Dongar%2FScreenshot%202025-12-16%20033853.png?alt=media&token=66cca787-13a2-4556-882e-0494b8d0b38d"]'::JSON 
WHERE place_name = 'Devacha Dongar';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F61-Mandangad%20Fort%2FScreenshot%202025-12-16%20033927.png?alt=media&token=59f4f093-e490-4c9f-be0d-36d46b7e3a5d", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F61-Mandangad%20Fort%2FScreenshot%202025-12-16%20033934.png?alt=media&token=f8cca51d-3b57-4f65-90bb-f2cff21162c8", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F61-Mandangad%20Fort%2FScreenshot%202025-12-16%20033943.png?alt=media&token=0ce0f033-b1ac-471d-8e29-710c52e052e8"]'::JSON 
WHERE place_name = 'Mandangad Fort';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F62-Bankot%20Fort%20(Himmatgad)%2FScreenshot%202025-12-16%20034046.png?alt=media&token=0620e05f-d5da-4d61-8bd5-1634822dfd45", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F62-Bankot%20Fort%20(Himmatgad)%2FScreenshot%202025-12-16%20034055.png?alt=media&token=4ce9e7a0-f969-4e8a-9050-8cecf380f345"]'::JSON 
WHERE place_name = 'Bankot Fort (Himmatgad)';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F63-Parshuram%20Temple%20(Chiplun)%2FScreenshot%202025-12-16%20034147.png?alt=media&token=8be53b10-19fa-4d29-bde8-8157cfd665a5", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F63-Parshuram%20Temple%20(Chiplun)%2FScreenshot%202025-12-16%20034154.png?alt=media&token=451572d6-93b6-4a7f-9698-f825fa9450ce", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F63-Parshuram%20Temple%20(Chiplun)%2FScreenshot%202025-12-16%20034202.png?alt=media&token=c7495632-2845-4277-bafa-29f3e78055fa"]'::JSON 
WHERE place_name = 'Parshuram Temple (Chiplun)';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F64-Ambadwe%20(Ambedkar%E2%80%99s%20ancestral%20village%20%26%20Memorial)%2FScreenshot%202025-12-16%20034306.png?alt=media&token=9dd716e0-669e-44a0-8dfd-c8934992b859", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F64-Ambadwe%20(Ambedkar%E2%80%99s%20ancestral%20village%20%26%20Memorial)%2FScreenshot%202025-12-16%20034328.png?alt=media&token=a6b3c3cd-2dab-4610-a815-382f72fa398a"]'::JSON 
WHERE place_name = 'Ambadwe (Ambedkar’s ancestral village & Memorial)';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F65-Pajpandhari%2FScreenshot%202025-12-16%20034404.png?alt=media&token=a1fd2a19-9300-4936-97cf-a3565636d535", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F65-Pajpandhari%2FScreenshot%202025-12-16%20034426.png?alt=media&token=2b869ca7-e82d-4c09-81b3-a77845028347", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F65-Pajpandhari%2FScreenshot%202025-12-16%20034433.png?alt=media&token=d0ee5612-fd8a-4fe7-90d5-483f410c8164"]'::JSON 
WHERE place_name = 'Pajpandhari';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F66-Panhale%20Durg%20Fort%2FScreenshot%202025-12-16%20034507.png?alt=media&token=caed37aa-d9de-4265-8ef2-95aa9ea8c901", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F66-Panhale%20Durg%20Fort%2FScreenshot%202025-12-16%20034526.png?alt=media&token=8468e003-5b1d-4ca3-9439-2e9be78515cf"]'::JSON 
WHERE place_name = 'Panhale Durg Fort';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F67-Palgad%2FScreenshot%202025-12-16%20034606.png?alt=media&token=9b73ccf2-ae54-484b-ab11-2cbe3212cfc1", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F67-Palgad%2FScreenshot%202025-12-16%20034617.png?alt=media&token=6a8e626d-b6ad-423e-87e2-f5f237d8ea5b", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F67-Palgad%2FScreenshot%202025-12-16%20034628.png?alt=media&token=2eb0e4bd-7f7c-4676-a27d-c9dc82b37ed9"]'::JSON 
WHERE place_name = 'Palgad';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F68-Unhavare%20Hot%20Water%20Springs%2FScreenshot%202025-12-16%20034709.png?alt=media&token=47b575ad-61a6-420b-ab8f-8a3006ab3cd8", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F68-Unhavare%20Hot%20Water%20Springs%2FScreenshot%202025-12-16%20034718.png?alt=media&token=f6a03ce3-123d-43b2-962f-fa0851d9d7d5", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F68-Unhavare%20Hot%20Water%20Springs%2FScreenshot%202025-12-16%20034728.png?alt=media&token=fef5abc5-843b-4938-b396-aa67e7dd370d"]'::JSON 
WHERE place_name = 'Unhavare Hot Water Springs';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F69-Murud%2FScreenshot%202025-12-16%20034759.png?alt=media&token=8c03c87a-10eb-4e64-9a15-3bda87655bd4", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F69-Murud%2FScreenshot%202025-12-16%20034812.png?alt=media&token=7449860b-2a1b-48d5-9068-7c40781e0114"]'::JSON 
WHERE place_name = 'Murud';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F70-Vanand%20Village%2FScreenshot%202025-12-16%20034900.png?alt=media&token=3b862d41-4ea1-46fd-9570-f7ae61705b33", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F70-Vanand%20Village%2FScreenshot%202025-12-16%20034920.png?alt=media&token=3fe185b9-e3c3-470e-afe6-1eb0787245f6"]'::JSON 
WHERE place_name = 'Vanand Village';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F71-Nageshwar%20temple%2C%20ChorvaneNageshwar%20temple%2C%20Chorvane%2FScreenshot%202025-12-16%20034950.png?alt=media&token=2cd73380-a9f0-4886-aa0d-40c9647c6129", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F71-Nageshwar%20temple%2C%20ChorvaneNageshwar%20temple%2C%20Chorvane%2FScreenshot%202025-12-16%20035005.png?alt=media&token=b2cd1636-5bbd-4e47-abdc-dc1174eb9c9b", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F71-Nageshwar%20temple%2C%20ChorvaneNageshwar%20temple%2C%20Chorvane%2FScreenshot%202025-12-16%20035013.png?alt=media&token=e4f525b3-3ab3-4564-817d-1814c5fbb4c1"]'::JSON 
WHERE place_name = 'Nageshwar temple, ChorvaneNageshwar temple, Chorvane';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F72-Shree%20ramvardayani%20mandir%2C%20chorvane%2FScreenshot%202025-12-16%20035048.png?alt=media&token=c1da63b7-fb38-4dc9-8ae2-eb33fdbc2858", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F72-Shree%20ramvardayani%20mandir%2C%20chorvane%2FScreenshot%202025-12-16%20035057.png?alt=media&token=8db48e7f-6eb4-46bb-88c9-b38457250cfe"]'::JSON 
WHERE place_name = 'Shree ramvardayani mandir, chorvane';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F73-Kartel%2FScreenshot%202025-12-16%20035133.png?alt=media&token=9b29c98f-2a0d-4ce0-94a9-84b74a68b5de", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F73-Kartel%2FScreenshot%202025-12-16%20035143.png?alt=media&token=11bc59fd-a576-4f3c-bd97-805cc707a83b"]'::JSON 
WHERE place_name = 'Kartel';

UPDATE tourist_locations 
SET firebase_storage_images_json = '[]'::JSON 
WHERE place_name = 'Wadibeldar';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F75-Songaon%20Mangrove%20Ecotourism%20%26%20Crocodile%20Safari%2FScreenshot%202025-12-16%20035228.png?alt=media&token=bca3a009-7339-42b4-b90a-ddc4cc4b33a0", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F75-Songaon%20Mangrove%20Ecotourism%20%26%20Crocodile%20Safari%2FScreenshot%202025-12-16%20035254.png?alt=media&token=f8141933-dd73-46c0-83e0-9a0f779a3b1c"]'::JSON 
WHERE place_name = 'Songaon Mangrove Ecotourism & Crocodile Safari';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F76-Bhuleshwar%20Shiva%20Temple%2C%20Furus%20Khed%2FScreenshot%202025-12-16%20035337.png?alt=media&token=2febe47e-9555-4b03-bbfb-1567b38766a3", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F76-Bhuleshwar%20Shiva%20Temple%2C%20Furus%20Khed%2FScreenshot%202025-12-16%20035357.png?alt=media&token=28e8575e-2837-4d92-bc71-3b2a8376913b"]'::JSON 
WHERE place_name = 'Bhuleshwar Shiva Temple, Furus Khed';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F77-Mahipatgad%2FScreenshot%202025-12-16%20035431.png?alt=media&token=222e58c6-5fb7-435a-8908-b5da198220ff", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F77-Mahipatgad%2FScreenshot%202025-12-16%20035440.png?alt=media&token=e4f48cb6-7a46-4997-bdac-1ccd107c6e20"]'::JSON 
WHERE place_name = 'Mahipatgad';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F78-Sumargad%2FScreenshot%202025-12-16%20035514.png?alt=media&token=7755be99-7449-4b32-8956-576ac03e2f37"]'::JSON 
WHERE place_name = 'Sumargad';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F79-Rasalgad%2FScreenshot%202025-12-16%20035557.png?alt=media&token=3c44fb3a-a8fd-4903-9b82-898784a9a600", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F79-Rasalgad%2FScreenshot%202025-12-16%20035608.png?alt=media&token=a9542b68-e0aa-45a2-a5ed-dc33e4eb6179"]'::JSON 
WHERE place_name = 'Rasalgad';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F80-Paldurg%20Fort%2FScreenshot%202025-12-16%20035716.png?alt=media&token=07c9ffd5-97e7-47c3-836c-ed50606731da"]'::JSON 
WHERE place_name = 'Paldurg Fort';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F81-Raghuveer%20Ghat%2FScreenshot%202025-12-16%20035803.png?alt=media&token=b3a72f1d-8dff-418f-8acf-0f5731da1544", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F81-Raghuveer%20Ghat%2FScreenshot%202025-12-16%20035812.png?alt=media&token=937cc4af-fc93-453e-be3c-8cd7f0b0506d"]'::JSON 
WHERE place_name = 'Raghuveer Ghat';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F82-Caves%20at%20Khed%2FScreenshot%202025-12-16%20035842.png?alt=media&token=63a792c6-59d4-446c-8c0e-f5064dfde774", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F82-Caves%20at%20Khed%2FScreenshot%202025-12-16%20035852.png?alt=media&token=fa531f06-3127-4e4e-a72f-046f3d621d5d"]'::JSON 
WHERE place_name = 'Caves at Khed';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F83-Shri%20Kalkai%20Temple%20(Bharane)%2FScreenshot%202025-12-16%20035923.png?alt=media&token=e32bd741-7157-4278-80b4-8b4e8078cc42", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F83-Shri%20Kalkai%20Temple%20(Bharane)%2FScreenshot%202025-12-16%20035930.png?alt=media&token=20344cde-bdf2-41f2-b7b0-3255c987f478"]'::JSON 
WHERE place_name = 'Shri Kalkai Temple (Bharane)';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F84-Niribaji%20Waterfall%20(Khandoshi%20Village)%2FScreenshot%202025-12-16%20040001.png?alt=media&token=63d865e9-5e79-4605-a269-f61fda9bc977", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F84-Niribaji%20Waterfall%20(Khandoshi%20Village)%2FScreenshot%202025-12-16%20040010.png?alt=media&token=6aff972e-6dea-47e5-a363-eecde4710aaf"]'::JSON 
WHERE place_name = 'Niribaji Waterfall (Khandoshi Village)';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F85-Anari%2FScreenshot%202025-12-16%20040052.png?alt=media&token=46b8656c-2e2e-4c96-ab16-fcb7fd65b6ba"]'::JSON 
WHERE place_name = 'Anari';

UPDATE tourist_locations 
SET firebase_storage_images_json = '[]'::JSON 
WHERE place_name = 'Dalwatne';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F87-Gandhareshwar%2FScreenshot%202025-12-16%20040223.png?alt=media&token=8e8ee121-e59b-48d3-a10f-db72868db7e3", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F87-Gandhareshwar%2FScreenshot%202025-12-16%20040232.png?alt=media&token=bf99c3ae-897a-41d5-9298-cc8d6c4e1b1d", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F87-Gandhareshwar%2FScreenshot%202025-12-16%20040240.png?alt=media&token=aa441f37-4b10-4871-8916-b1ab51161070", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F87-Gandhareshwar%2FScreenshot%202025-12-16%20040248.png?alt=media&token=376f2831-f216-4853-a8d0-e404d8304af4"]'::JSON 
WHERE place_name = 'Gandhareshwar';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F88-Adare%2FScreenshot%202025-12-16%20040336.png?alt=media&token=31cddca1-1046-4c9b-9f7c-5c50d5d36b7b"]'::JSON 
WHERE place_name = 'Adare';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F89-Goval%20Kot%20Fort%2FScreenshot%202025-12-16%20040406.png?alt=media&token=81eb92dc-579a-4170-8a29-79e4174f7285", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F89-Goval%20Kot%20Fort%2FScreenshot%202025-12-16%20040415.png?alt=media&token=221ac73d-1fe8-4c87-b43e-d8cf0732a64a"]'::JSON 
WHERE place_name = 'Goval Kot Fort';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F90-Kolkewadi%20Durg%2FScreenshot%202025-12-16%20040454.png?alt=media&token=b7361d6e-81f4-4438-974d-d49f1c4dfe71", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F90-Kolkewadi%20Durg%2FScreenshot%202025-12-16%20040507.png?alt=media&token=92454c9a-781f-4043-a719-616e9ea0b391"]'::JSON 
WHERE place_name = 'Kolkewadi Durg';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F91-Bhairavgad%2FScreenshot%202025-12-16%20040557.png?alt=media&token=667ea14b-7953-4a6d-be18-06b469f8a325"]'::JSON 
WHERE place_name = 'Bhairavgad';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F92-Derwan%2FScreenshot%202025-12-16%20040634.png?alt=media&token=0b42f3be-0b86-42c4-987d-be10aed82162", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F92-Derwan%2FScreenshot%202025-12-16%20040641.png?alt=media&token=30b580e6-9882-4d0b-9b6d-4777d7cf1aae"]'::JSON 
WHERE place_name = 'Derwan';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F93-Sawatsada%20Waterfall%2FScreenshot%202025-12-16%20040714.png?alt=media&token=c506b3b4-941f-4ca4-8d67-311c23c42ae9", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F93-Sawatsada%20Waterfall%2FScreenshot%202025-12-16%20040721.png?alt=media&token=c79dc26b-2fde-43cf-b093-44dde9ec4e9c", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F93-Sawatsada%20Waterfall%2FScreenshot%202025-12-16%20040730.png?alt=media&token=33042b03-2d82-49e5-9721-0623a8986aa9"]'::JSON 
WHERE place_name = 'Sawatsada Waterfall';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F94-Sharada%20Devi%20Temple%20(Turambav)%2FScreenshot%202025-12-16%20040807.png?alt=media&token=69382fcb-72dc-4513-8767-83418186dbf7", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F94-Sharada%20Devi%20Temple%20(Turambav)%2FScreenshot%202025-12-16%20040816.png?alt=media&token=fcc569c6-cc27-4da7-85dd-12a20f21acec"]'::JSON 
WHERE place_name = 'Sharada Devi Temple (Turambav)';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F95-Kulswamini%20Bhavani%20Waghjai%20Temple%20(Terev)%2FScreenshot%202025-12-16%20040851.png?alt=media&token=652015db-ac6b-4e45-809f-da05f110a96b"]'::JSON 
WHERE place_name = 'Kulswamini Bhavani Waghjai Temple (Terev)';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F96-Devi%20Karanjeshwari%20Temple%20(Goval%20Kot)%2FScreenshot%202025-12-16%20040930.png?alt=media&token=10a8d7ac-c3c2-4b7c-b027-de93a3cb0fd8", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F96-Devi%20Karanjeshwari%20Temple%20(Goval%20Kot)%2FScreenshot%202025-12-16%20040939.png?alt=media&token=e3bb12de-70a8-4df1-a150-576716b15b51", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F96-Devi%20Karanjeshwari%20Temple%20(Goval%20Kot)%2FScreenshot%202025-12-16%20040947.png?alt=media&token=83a8a79e-139b-4151-a160-d34ec2fd87d5"]'::JSON 
WHERE place_name = 'Devi Karanjeshwari Temple (Goval Kot)';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F97-Pandav-era%20Caves%20%2C%20Peer%20Baba%20Dargah%2FScreenshot%202025-12-16%20041022.png?alt=media&token=4db82fd9-6638-428a-b7c9-875c5458d056", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F97-Pandav-era%20Caves%20%2C%20Peer%20Baba%20Dargah%2FScreenshot%202025-12-16%20041038.png?alt=media&token=d94d4fde-4885-4504-af6c-0bdf8ab98dfd"]'::JSON 
WHERE place_name = 'Pandav-era Caves , Peer Baba Dargah';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F98-Vijaygad%2FScreenshot%202025-12-16%20041113.png?alt=media&token=c3bd15e1-b34f-428f-b607-fbf3c25f1e18", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F98-Vijaygad%2FScreenshot%202025-12-16%20041120.png?alt=media&token=908eb90e-db1d-454e-82dc-ccbda6ed43a7"]'::JSON 
WHERE place_name = 'Vijaygad';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F99-Modka%20Depot%2FScreenshot%202025-12-16%20041230.png?alt=media&token=b498afc7-abe8-41b8-ad23-0c9d6038c568"]'::JSON 
WHERE place_name = 'Modka Depot';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F100-Durga%20Devi%20Temple%20(Budhal)%2FScreenshot%202025-12-16%20041309.png?alt=media&token=cfe96780-6a0e-47a1-b710-b3a26b1e3fe7", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F100-Durga%20Devi%20Temple%20(Budhal)%2FScreenshot%202025-12-16%20041316.png?alt=media&token=05abcf59-7cae-4a8b-943d-052ac05ccf0e"]'::JSON 
WHERE place_name = 'Durga Devi Temple (Budhal)';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F101-Kotaluk%2FScreenshot%202025-12-16%20041426.png?alt=media&token=ba294c3a-f9bb-4e90-aaa9-44f6e1ae6e35"]'::JSON 
WHERE place_name = 'Kotaluk';

UPDATE tourist_locations 
SET firebase_storage_images_json = '[]'::JSON 
WHERE place_name = 'Varaveli- Vervali';

UPDATE tourist_locations 
SET firebase_storage_images_json = '[]'::JSON 
WHERE place_name = 'Sakhari Depot';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F104-Shirgaon%2FScreenshot%202025-12-16%20041550.png?alt=media&token=8140b261-2898-4289-b832-78cd094e8a6b"]'::JSON 
WHERE place_name = 'Shirgaon';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F105-Bhavanigad%2FScreenshot%202025-12-16%20041638.png?alt=media&token=a837ceef-1ace-4c4b-8bc8-f4de92877d36", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F105-Bhavanigad%2FScreenshot%202025-12-16%20041652.png?alt=media&token=4a08589f-e007-46a1-8db2-ef2516fafb76"]'::JSON 
WHERE place_name = 'Bhavanigad';

UPDATE tourist_locations 
SET firebase_storage_images_json = '[]'::JSON 
WHERE place_name = 'Prachitgad';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F107-Mahipatgad%2FScreenshot%202025-12-16%20041805.png?alt=media&token=cac6f36c-c6bb-4048-89ec-b44db7747017"]'::JSON 
WHERE place_name = 'Mahipatgad';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F108-Shri%20Karneshwar%20Temple%2FScreenshot%202025-12-16%20041846.png?alt=media&token=2a1c6c49-2c30-4f4e-99a1-26e836fdb292", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F108-Shri%20Karneshwar%20Temple%2FScreenshot%202025-12-16%20041857.png?alt=media&token=8a32c4db-380c-4fa5-ae1f-44efda93d16b"]'::JSON 
WHERE place_name = 'Shri Karneshwar Temple';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F109-Machal%2FScreenshot%202025-12-16%20041931.png?alt=media&token=b22cf241-41fc-4e65-b6dd-4013d5fc87ce", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F109-Machal%2FScreenshot%202025-12-16%20041942.png?alt=media&token=d7f260fb-a6bc-4a57-b6f5-5f83d1276935"]'::JSON 
WHERE place_name = 'Machal';

UPDATE tourist_locations 
SET firebase_storage_images_json = '[]'::JSON 
WHERE place_name = 'Math';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F111-Satavali%20Fort%2FScreenshot%202025-12-16%20042035.png?alt=media&token=1741c6c6-5e41-48ae-956b-8661bf13fcf5", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F111-Satavali%20Fort%2FScreenshot%202025-12-16%20042046.png?alt=media&token=0100a6f8-83fb-4ac6-93f2-32638f5154ac"]'::JSON 
WHERE place_name = 'Satavali Fort';

UPDATE tourist_locations 
SET firebase_storage_images_json = '[]'::JSON 
WHERE place_name = 'Rani Laxmibai Memorial (Mouje Kot)';

UPDATE tourist_locations 
SET firebase_storage_images_json = '[]'::JSON 
WHERE place_name = 'Gangu’s Bowl (Bapere Zorewadi)';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F114-Pawas%2FScreenshot%202025-12-16%20042153.png?alt=media&token=5171c852-9b7c-4c02-a6e4-01e02d6da12c"]'::JSON 
WHERE place_name = 'Pawas';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F115-Hatis%2FScreenshot%202025-12-16%20042249.png?alt=media&token=ee258e59-d417-4c5d-9ac7-20c3a12db303"]'::JSON 
WHERE place_name = 'Hatis';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F116-Ratnagiri%20City%2FScreenshot%202025-12-16%20042322.png?alt=media&token=30722d9f-82a0-4519-8e26-e8ab77c8612e", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F116-Ratnagiri%20City%2FScreenshot%202025-12-16%20042335.png?alt=media&token=2e6690c9-98ff-4114-aa93-a3f3d4091f31", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F116-Ratnagiri%20City%2FScreenshot%202025-12-16%20042345.png?alt=media&token=d11b5fbf-6263-4717-b0f2-82e050bcb3a9"]'::JSON 
WHERE place_name = 'Ratnagiri City';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F117-Nirul%2FScreenshot%202025-12-16%20042435.png?alt=media&token=33c72d75-b482-471d-93c9-100f6fbed8c0"]'::JSON 
WHERE place_name = 'Nirul';

UPDATE tourist_locations 
SET firebase_storage_images_json = '[]'::JSON 
WHERE place_name = 'Nivali Waterfall';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F119-Kalbadevi%20Temple%20and%20Beach%2FScreenshot%202025-12-16%20042534.png?alt=media&token=095e3778-de0b-486a-a445-dce558d6e5a9", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F119-Kalbadevi%20Temple%20and%20Beach%2FScreenshot%202025-12-16%20042542.png?alt=media&token=ca6e6461-7f5d-42ae-835b-6fed3c14ea80"]'::JSON 
WHERE place_name = 'Kalbadevi Temple and Beach';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F120-Shil%20Dam%2FScreenshot%202025-12-16%20042625.png?alt=media&token=f82dc7c2-1393-47f6-b749-14d20dc1cd8e", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F120-Shil%20Dam%2FScreenshot%202025-12-16%20042635.png?alt=media&token=f03f6eed-ef5c-4d0f-b90f-7627c4df057d", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F120-Shil%20Dam%2FScreenshot%202025-12-16%20042642.png?alt=media&token=817e5ebf-7065-49d3-bf5c-8de562d7cc20"]'::JSON 
WHERE place_name = 'Shil Dam';

UPDATE tourist_locations 
SET firebase_storage_images_json = '[]'::JSON 
WHERE place_name = 'Rantal';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F122-Dhopeshwar%20Temple%2FScreenshot%202025-12-16%20042750.png?alt=media&token=4c5d7a98-61f1-4700-9c9f-66a55dac4c51", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F122-Dhopeshwar%20Temple%2FScreenshot%202025-12-16%20042758.png?alt=media&token=ab8add0a-80de-4c4f-84a2-ff436870df1d"]'::JSON 
WHERE place_name = 'Dhopeshwar Temple';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F123-Chunakolwan%2FScreenshot%202025-12-16%20042838.png?alt=media&token=e1d0d198-02e6-44b5-a4ab-20e9b86638c0", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F123-Chunakolwan%2FScreenshot%202025-12-16%20042846.png?alt=media&token=7e8b563f-3b98-4a32-bfb5-14e7868af137"]'::JSON 
WHERE place_name = 'Chunakolwan';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F124-Yashwantgad%2FScreenshot%202025-12-16%20042916.png?alt=media&token=0dbf3301-1e26-4678-b353-f8abdcf2e6b5"]'::JSON 
WHERE place_name = 'Yashwantgad';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F125-Rajapur%20Fort%2FScreenshot%202025-12-16%20043000.png?alt=media&token=85eb6602-420c-4ae2-9d00-8b90c41a478b", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F125-Rajapur%20Fort%2FScreenshot%202025-12-16%20043014.png?alt=media&token=0e1201a5-3225-48a4-8ebd-e9c7b996ab6d"]'::JSON 
WHERE place_name = 'Rajapur Fort';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F126-Gangatirth%20%26%20Hot%20Water%20Spring%2FScreenshot%202025-12-16%20043050.png?alt=media&token=87e906a9-d4d4-4082-a3bc-62dca66d160d"]'::JSON 
WHERE place_name = 'Gangatirth & Hot Water Spring';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F127-Rock%20Carvings%20(Rajapur%20Taluka)%2FScreenshot%202025-12-16%20043138.png?alt=media&token=c7d4eca0-4cec-4cdf-922b-67ba1549c1b7"]'::JSON 
WHERE place_name = 'Rock Carvings (Rajapur Taluka)';

UPDATE tourist_locations 
SET firebase_storage_images_json = '[]'::JSON 
WHERE place_name = 'Mouje Soundal';

UPDATE tourist_locations 
SET firebase_storage_images_json = '[]'::JSON 
WHERE place_name = 'Ozar Waterfall (Ghagwadi)';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F130-Savatkada%20waterfall%2FScreenshot%202025-12-16%20043343.png?alt=media&token=2234f7f8-a920-4195-b996-bf6fe62181ed", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F130-Savatkada%20waterfall%2FScreenshot%202025-12-16%20043355.png?alt=media&token=e991babc-741f-4b86-89d2-1f585614fce0"]'::JSON 
WHERE place_name = 'Savatkada waterfall';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F131-Phansavle%20Bridge%2FScreenshot%202025-12-16%20043429.png?alt=media&token=0a9e12c2-0ed9-43dc-8769-5f8ab9d115f1"]'::JSON 
WHERE place_name = 'Phansavle Bridge';

UPDATE tourist_locations 
SET firebase_storage_images_json = '["https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F132-Patit%20Pavan%20Temple%2FScreenshot%202025-12-16%20043526.png?alt=media&token=dc22a66a-baa4-4caa-8922-12c0d0c26328", "https://firebasestorage.googleapis.com/v0/b/samudrayan-fdce7.firebasestorage.app/o/tourism-spots%2F132-Patit%20Pavan%20Temple%2FScreenshot%202025-12-16%20043536.png?alt=media&token=f476eef6-d6d7-4b40-bd56-ca748ba747b7"]'::JSON 
WHERE place_name = 'Patit Pavan Temple';

UPDATE tourist_locations 
SET firebase_storage_images_json = '[]'::JSON 
WHERE place_name = 'Mallika arjun temple';


-- Step 3: Drop the old TEXT column
ALTER TABLE tourist_locations DROP COLUMN firebase_storage_images;

-- Step 4: Rename the new JSON column to the original name
ALTER TABLE tourist_locations RENAME COLUMN firebase_storage_images_json TO firebase_storage_images;

-- Step 5: Add a check constraint to ensure valid JSON (PostgreSQL 12+ syntax)
-- For older versions, remove this constraint
ALTER TABLE tourist_locations ADD CONSTRAINT firebase_images_valid_json 
  CHECK (firebase_storage_images IS NULL OR firebase_storage_images::text::json IS NOT NULL);

-- Step 6: Create an index on the JSON column for better query performance
CREATE INDEX IF NOT EXISTS idx_tourist_locations_firebase_images_gin 
  ON tourist_locations USING GIN (firebase_storage_images);

-- Commit the transaction
COMMIT;

-- Verification queries
SELECT 
    place_name, 
    JSON_ARRAY_LENGTH(firebase_storage_images) as image_count,
    firebase_storage_images->0 as first_image_url
FROM tourist_locations 
WHERE firebase_storage_images IS NOT NULL
ORDER BY place_name
LIMIT 5;

-- Count total locations updated
SELECT COUNT(*) as total_locations_with_images 
FROM tourist_locations 
WHERE firebase_storage_images IS NOT NULL;
