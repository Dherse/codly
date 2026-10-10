#import "../codly.typ" as codly

#import "_common.typ": frame
#show: frame

// A realistic patch: retry only transient failures, add a timeout, and back off.
#let rows = (
  "+import time",
  "+",
  " import requests",
  " ",
  " def fetch_json(url: str, attempts: int = 3) -> dict:",
  "-    \"\"\"Fetch JSON, retrying any request failure.\"\"\"",
  "+    \"\"\"Fetch JSON with bounded retries and exponential backoff.\"\"\"",
  "     for attempt in range(attempts):",
  "         try:",
  "-            response = requests.get(url)",
  "+            response = requests.get(url, timeout=5)",
  "             response.raise_for_status()",
  "             return response.json()",
  "-        except requests.RequestException:",
  "+        except (requests.Timeout, requests.ConnectionError):",
  "             if attempt == attempts - 1:",
  "                 raise",
  "+            delay = min(0.5 * 2**attempt, 8)",
  "+            time.sleep(delay)",
)
#let old-count = rows.filter(row => not row.starts-with("+")).len()
#let new-count = rows.filter(row => not row.starts-with("-")).len()
#let patch = "@@ -1," + str(old-count) + " +1," + str(new-count) + " @@\n" + rows.join("\n")

#let example() = {
  set text(size: 9pt)
  codly.new(
    raw(patch, lang: "diff,py", block: true),
    file: "client.py",
    header: [Bounded HTTP retries],
    indent-guides: (width: 4),
    wrap-marker: [↪],
  )
}

#{
  show: codly.theme("github-light")
  example()
}
