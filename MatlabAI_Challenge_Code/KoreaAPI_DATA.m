% === SETUP ===
apiKey = 'Insert your API here';
stationName = '서대문구';
apiKey = urlencode(apiKey);  % NEW

% === BUILD URL ===
url = ['http://apis.data.go.kr/B552584/ArpltnInforInqireSvc/' ...
       'getMsrstnAcctoRltmMesureDnsty?stationName=' urlencode(stationName) ...
       '&dataTerm=DAILY&pageNo=1&numOfRows=1&returnType=xml' ...
       '&serviceKey=' apiKey '&ver=1.3'];

% === GET RAW XML AS TEXT ===
options = weboptions('ContentType', 'text', 'Timeout', 15);
rawXml = webread(url, options);

% === PARSE XML ===
xmlDoc = xmlreadstring(rawXml);  % Must exist in the same folder

% === GET FIRST <item> ELEMENT ===
itemNodes = xmlDoc.getElementsByTagName('item');
if itemNodes.getLength() == 0
    error('No <item> found in the XML.');
end
firstItem = itemNodes.item(0);

% === SAFE TAG VALUE FUNCTION ===
getTagValue = @(tag) getSafeTagValue(firstItem, tag);

function val = getSafeTagValue(node, tag)
    try
        tagNode = node.getElementsByTagName(tag);
        if tagNode.getLength() > 0 && tagNode.item(0).hasChildNodes()
            val = char(tagNode.item(0).getFirstChild().getData());
        else
            val = 'NaN';
        end
    catch
        val = 'NaN';
    end
end

% === EXTRACT VALUES ===
parseValue = @(tag) str2double(strrep(getTagValue(tag), '-', 'NaN'));

pm25 = parseValue('pm25Value');
pm10 = parseValue('pm10Value');
o3 = parseValue('o3Value');
no2 = parseValue('no2Value');
co = parseValue('coValue');
so2 = parseValue('so2Value');
khaiIndex = parseValue('khaiValue');
timestamp = getTagValue('dataTime');

% === DISPLAY RESULTS ===
fprintf('\n--- Air Quality at %s ---\n', stationName);
fprintf('Time: %s\n', timestamp);
fprintf('PM2.5: %.1f µg/m³\n', pm25);
fprintf('PM10: %.1f µg/m³\n', pm10);
fprintf('O₃: %.3f ppm\n', o3);
fprintf('NO₂: %.3f ppm\n', no2);
fprintf('CO: %.1f ppm\n', co);
fprintf('SO₂: %.3f ppm\n', so2);
fprintf('KHAI Index: %d\n', khaiIndex);