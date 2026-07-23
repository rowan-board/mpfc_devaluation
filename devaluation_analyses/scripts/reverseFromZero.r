## function to take vector of trial numbers and count backwards from the last trial
# column name that you are reversing has to be called trailNr
# save the vector as an object in r e.g x <- reverseFromZero(df)

reverseFromZero <- function(df) {
  # then lets make them a vector, reverse them, turn back into df
  st <- df$trialNr
  st <- as.data.frame(st)
  st$st <- rev(st$st)
  
  # add the rowid to column and set a column of 0s called adaptedTrialNr
  st <- st %>%
    rowid_to_column
  st['adaptedTrialNr'] = 0
  
  # if state time is larger than the state time on the preceding row
  # then we've entered a new state 4, so set this trial no. to -1
  for (i in st$rowid) {
    if (st[i,]$rowid == 1) next
    if (st[i,]$st > st[i-1,]$st){
      st[i,]$adaptedTrialNr = -1
    }
  }
  
  # if state time is smaller than the state time on the preceding row
  # then we're in the same state and the trial no. needs to be 1 less 
  # than the row preceding it
  for (i in st$rowid) {
    if (st[i,]$rowid == 1) next
    if (st[i,]$st < st[i-1,]$st){
      st[i,]$adaptedTrialNr = st[i-1,]$adaptedTrialNr - 1
    } 
  }
  
  # some states are of length 1, these have remained 0 so make them -1s
  for (i in st$rowid) {
    if (st[i,]$adaptedTrialNr == 0){
      st[i,]$adaptedTrialNr = -1
    }
  }
  
  # now we have the full adapted trial number for the state, make a vector
  adaptedTrialNr <- rev(st$adaptedTrialNr)
  
}