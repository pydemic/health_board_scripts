const YAML = require('yamljs')
const fs = require('fs')
const { exec } = require('child_process')

/* ###### SETTINGS ###### */
const inputFileName = 'sections.yml'
const outputFileName = 'sections.csv'
const outputFileNameCards = 'sections_cards.csv'
const outputFileNameFilters = 'sections_cards_filters.csv'

const sectionKeys = [ 'name', 'description', 'cards' ]
const cardKeys = [ 'card_id', 'name', 'link', 'filters' ]
/* ###### SETTINGS END ###### */

const data = YAML.load('./INPUT/'+inputFileName)

let output = ''
let outputCards = ''
let outputFilters = ''

Object.keys(data).forEach( item => {
  output = output + '\"' + item + '\"' + ','
  let line = []

  sectionKeys.forEach( (dataField, key) => {
    if(dataField !== 'cards'){
      if(data[item][dataField]){
        line.push('\"' + data[item][dataField] + '\"')
      } else {
        line.push('')
      }
    } else {
      Object.keys(data[item][dataField]).forEach(card =>{
        let lineCard = []
        let lineFilters = []
        
        lineCard.push('\"' + item + '\"')

        cardKeys.forEach( cardKey => {
          if(data[item][dataField][card][cardKey] && cardKey !== 'link' && cardKey !== 'filters'){
            lineCard.push('\"' + data[item][dataField][card][cardKey] + '\"')
            if(cardKey === 'card_id') {
               lineCard.push('\"' + card + '\"')
            }
          } else {
            if(cardKey === 'link'){
              if(typeof(data[item][dataField][card][cardKey]) === 'boolean'){
                if(data[item][dataField][card][cardKey]) {
                  lineCard.push('\"1\"')
                } else {
                  lineCard.push('\"0\"')
                }
              } else {
                lineCard.push('\"1\"')
              }
            } else {
              if(cardKey === 'filters'){
                if(data[item][dataField][card][cardKey]){
                  Object.keys(data[item][dataField][card][cardKey]).forEach(filter => {
  
                    lineFilters.push('\"' + card + '\"')
                    lineFilters.push('\"' + filter + '\"')
    
                    if(Array.isArray(data[item][dataField][card][cardKey][filter])){
                      lineFilters.push('\"' + data[item][dataField][card][cardKey][filter].join(',').replace(/_/g, '') + '\"')
                    } else {
                      lineFilters.push('\"' + data[item][dataField][card][cardKey][filter].replace(/_/g, '') + '\"')
                    }
                    outputFilters = outputFilters + lineFilters.join(',') + '\n'
                  })
                }
              } else {
                lineCard.push('')
              }
            }
          }
        })
        outputCards = outputCards + lineCard.join(',') + '\n'
        
      })
    }
  })

  output = output + line.join(',') + '\n'
});

const sort = (fileName) => {
  exec(`sort -o ./OUTPUT/${fileName} ./OUTPUT/${fileName}`, (err, stdout, stderr) => {
    if (err) {
      console.log(`error: ${err}`)
      return;
    }
    if (stdout) {
      console.log(`stdout: ${stdout}`)
    }
    if (stderr) {
      console.log(`stderr: ${stderr}`)
    }
  });
}

fs.writeFile('./OUTPUT/'+outputFileName, output, function (err) {
  if (err) return console.log(err)
  console.log('file:'+outputFileName)
})

sort(outputFileName)

fs.writeFile('./OUTPUT/'+outputFileNameCards, outputCards, function (err) {
  if (err) return console.log(err)
  console.log('file:'+outputFileNameCards)
})

sort(outputFileNameCards)

fs.writeFile('./OUTPUT/'+outputFileNameFilters, outputFilters, function (err) {
  if (err) return console.log(err)
  console.log('file:'+outputFileNameFilters)
})

sort(outputFileNameFilters)



