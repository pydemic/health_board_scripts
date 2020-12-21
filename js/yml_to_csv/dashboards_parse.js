const YAML = require('yamljs')
const fs = require('fs')
const { exec } = require('child_process')


/* ###### SETTINGS ###### */
const inputFileName = 'dashboards.yml'
const outputFileName = 'dashboards.csv'
const outputFileNameGroups = 'dashboards_groups.csv'
const outputFileNameSections = 'groups_sections.csv'
const outputFileNameCards = 'sections_cards.csv'
const outputFileNameFilters = 'sections_cards_filters.csv'

const group_fields = [
  "index",
  "id",
  "name",
  "description",
  "sections"
]

const sections_fields = [
  "index",
  "id",
  "name",
  "description",
  "cards"
]
const cards_fields = [
  "index",
  "card_id",
  "section_card_id",
  "name",
  "link",
  "filters"
]
/* ###### SETTINGS END ###### */

const data = YAML.load('./INPUT/'+inputFileName)

let output = ''
let outputGroups = ''
let outputSections = ''
let outputCards = ''
let outputFilters = ''

Object.keys(data).forEach( item => {
  output = output + '\"' + item + '\"' + ','

  Object.keys(data[item]).forEach( (dataField) => {
    if(dataField !== 'groups'){
      output = output + '\"' + data[item][dataField] + '\"'
      if(dataField !== 'description'){
        output = output + ','
      }
    } else {
      Object.keys(data[item][dataField]).forEach(group => {
        let groupLine = ['\"' + item + '\"']
        group_fields.forEach(groupKey => {
          if (groupKey === 'id') {
              groupLine.push('\"' + group + '\"')
          } else if(groupKey !== 'sections'){
            groupLine.push('\"' + data[item][dataField][group][groupKey] + '\"')
          } else {
            const sections = data[item][dataField][group][groupKey]
            //Section
            if (sections){
              Object.keys(sections).forEach(section => {
                let sectionLine = ['\"' + group + '\"']
                sections_fields.forEach(sectionKey => {
                  // console.log(sectionKey+' '+ sections[section][sectionKey])
                  if (sectionKey === 'id') {
                    sectionLine.push('\"' + section + '\"')
                  } else if(sectionKey !== 'cards'){
                    sectionLine.push('\"' + sections[section][sectionKey] + '\"')
                  } else {
                    //Cards
                    const cards = sections[section][sectionKey]
                    if(cards) {
                      Object.keys(cards).forEach(card => {
                        let cardLine = ['\"' + section + '\"']
                        cards_fields.forEach(cardKey => {
                          // console.log(cardKey+' '+ cards[card][cardKey])
                          if (cardKey === 'section_card_id') {
                            cardLine.push('\"' + card + '\"')
                          } else if(cardKey !== 'filters'){
                            if(cardKey === 'link'){
                              if(typeof(cards[card][cardKey]) === 'boolean'){
                                if(cards[card][cardKey]) {
                                  cardLine.push('\"1\"')
                                } else {
                                  cardLine.push('\"0\"')
                                }
                              } else {
                                cardLine.push('\"1\"')
                              }
                            } else if(cards[card][cardKey]) {
                              cardLine.push('\"' + cards[card][cardKey] + '\"')
                            } else {
                              if(cardKey === 'index'){
                                cardLine.push('\"' + cards[card][cardKey] + '\"')
                              } else {
                                cardLine.push('\"' + "" + '\"')
                              }
                            }
                          } else {
                            //Filters
                            const filters = cards[card][cardKey]
                            // console.log(filters)
                            if(filters) {
                              Object.keys(filters).forEach(filter => {
                                let lineFilters = []
                                lineFilters.push('\"' + card + '\"')
                                lineFilters.push('\"' + filter + '\"')
                
                                if(Array.isArray(filters[filter])){
                                  lineFilters.push('\"' + filters[filter].join(',').replace(/_/g, '') + '\"')
                                } else {
                                  lineFilters.push('\"' + filters[filter].replace(/_/g, '') + '\"')
                                }

                                outputFilters = outputFilters + lineFilters.join(',') + '\n'
                              })
                            }
                          }
                        })
                        outputCards = outputCards + cardLine.join(',') + "\n"
                      })
                    }
                  }
                })
                outputSections = outputSections + sectionLine.join(',') + "\n"
              })
            }
          }
        })
        outputGroups = outputGroups + groupLine.join(',') + "\n"
      })
    }
  })

  const date = new Date()

  output = output + ',\"' + date.toISOString() + '\",\"' + date.toISOString() + '\"\n'
});


const sort = (fileName) => {
  exec(`sort -o ./OUTPUT/${fileName} ./OUTPUT/${fileName}`, (err, stdout, stderr) => {
    if (err) {
      console.log(`error: ${err}`)
      return;
    }
    if (stdout) {
      console.log(`stdout: ${stdout}`);
    }
    if (stderr) {
      console.log(`stderr: ${stderr}`);
    }
  });
}

fs.writeFile('./OUTPUT/'+outputFileName, output, function (err) {
  if (err) return console.log(err)
  console.log('file:'+outputFileName)
  sort(outputFileName)
})

fs.writeFile('./OUTPUT/'+outputFileNameGroups, outputGroups, function (err) {
  if (err) return console.log(err)
  console.log('file:'+outputFileNameGroups)
  sort(outputFileNameGroups)
})


fs.writeFile('./OUTPUT/'+outputFileNameSections, outputSections, function (err) {
  if (err) return console.log(err)
  console.log('file:'+outputFileNameSections)
  sort(outputFileNameSections)
})

fs.writeFile('./OUTPUT/'+outputFileNameCards, outputCards, function (err) {
  if (err) return console.log(err)
  console.log('file:'+outputFileNameCards)
  sort(outputFileNameCards)
})

fs.writeFile('./OUTPUT/'+outputFileNameFilters, outputFilters, function (err) {
  if (err) return console.log(err)
  console.log('file:'+outputFileNameFilters)
  sort(outputFileNameFilters)
})
