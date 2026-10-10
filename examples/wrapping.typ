#import "../codly.typ" as codly
#import "_common.typ": frame
#show: frame
#show: codly.theme("dark")

#codly.new(
  raw(
    "fn build_report(records: &[Record]) -> Report {\n    records.iter().filter(|record| record.is_ready()).map(|record| summarize(record, Options { include_history: true, include_metadata: true })).collect()\n}",
    lang: "rs",
    block: true,
  ),
  file: "report.rs",
  indent-guides: (width: 4),
  rainbow: true,
  wrap-marker: [↪],
  padding: (y: 4pt),
)
