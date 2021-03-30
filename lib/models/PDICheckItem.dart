class PDICheckItem {
  final String id;
  final String titleID;
  final String text;
  final String arbcText;

  PDICheckItem(this.id, this.titleID, this.text, this.arbcText);

  PDICheckItem.fromJSON(json):
    this.id = json["PDII_ID"],
    this.titleID = json["PDII_PDTL_ID"],
    this.text = json["PDII_TEXT"],
    this.arbcText = json["PDII_ARBC_TEXT"];
  
}

class PDICheckTitle {
  final String id;
  final String text;
  final String arbcText;

  PDICheckTitle(this.id, this.text, this.arbcText);

  PDICheckTitle.fromJSON(json):
    this.text = json["PDTL_TEXT"],
    this.arbcText = json["PDTL_ARBC_TEXT"],
    this.id = json["PDTL_ID"];
  
}


