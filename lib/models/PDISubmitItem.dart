class PDISubmitItem {
  String id;
  bool state;
  String comment;

  PDISubmitItem(this.id, this.state, this.comment);

  Map<String, dynamic> toJson() => {
        'id': id,
        'state': state,
        'comment': comment,
      };
}
