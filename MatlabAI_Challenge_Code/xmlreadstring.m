function xmlDoc = xmlreadstring(xmlString)
    import java.io.StringReader
    import javax.xml.parsers.DocumentBuilderFactory

    factory = DocumentBuilderFactory.newInstance();
    builder = factory.newDocumentBuilder();
    reader = StringReader(xmlString);
    inputSource = org.xml.sax.InputSource(reader);
    xmlDoc = builder.parse(inputSource);
end
