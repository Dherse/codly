#import "../../codly.typ": *

// Remove these lines to see the difference
#show: codly-init.with()
#codly(number-format: none, stroke: none, display-icon: false, display-name: false, inset: 0.205em)

#let code = ```py
import pandas as pd

def preprocess_headers(data: pd.DataFrame) -> None:
    data.columns = data.columns.str.title()

    # Rename columns to PascalCase
    data.rename(
        columns={
            "Placeofbirth": "PlaceOfBirth",
            "Stageid": "StageID",
            "Gradeid": "GradeID",
            "Sectionid": "SectionID",
            "Raisedhands": "RaisedHands",
            "Visitedresources": "VisitedResources",
            "Announcementsview": "AnnouncementsView",
            "Parentansweringsurvey": "ParentAnsweringSurvey",
            "Parentschoolsatisfaction": "ParentSchoolSatisfaction",
            "Studentabsencedays": "StudentAbsenceDays",
        },
        inplace=True,
        errors="raise",
    )

    # Replace values with correct ones
    data.loc[data["Relation"] == "Mum", "Relation"] = "Mother"
    data.loc[data["Nationality"] == "KW", "Nationality"] = "Kuwait"
    data.loc[data["PlaceOfBirth"] == "KuwaIT", "PlaceOfBirth"] = "Kuwait"
    data.loc[data["StageID"] == "lowerlevel", "StageID"] = "LowerLevel"

    # Ensure all lowercase values are capitalized (ignores values like USA)
    for col in ["Nationality", "PlaceOfBirth"]:
        data.loc[data[col].str.lower() == data[col], col] = data[col].str.title()

    # Convert object columns to categorical
    data_obj_dtypes = data.select_dtypes(include="object")
    data[data_obj_dtypes.columns] = data_obj_dtypes.astype("category")

    # Give some categorical columns an order and explicit categories
    grade_ids = [f"G-{i:02d}" for i in range(1, 13)]
    data["GradeID"] = data["GradeID"].cat.set_categories(grade_ids, ordered=True)
    data["Class"] = pd.Categorical(data["Class"], ordered=True, categories=["L", "M", "H"])
```

#set page("a3")
#columns(2)[
  #code
  #colbreak()
  #no-codly(code)
]