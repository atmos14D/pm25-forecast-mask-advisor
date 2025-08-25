function xmlDoc = xmlreadstring(xmlString)
    import java.io.StringReader
    import javax.xml.parsers.DocumentBuilderFactory
    import org.xml.sax.InputSource

    factory = DocumentBuilderFactory.newInstance();
    builder = factory.newDocumentBuilder();
    reader = StringReader(xmlString);
    inputSource = InputSource(reader);
    xmlDoc = builder.parse(inputSource);
end
