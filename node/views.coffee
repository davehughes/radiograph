
menuItem = (url, text, icon, file=false) ->
  li ->
    a href: @url ->
      i class: icon
      span text 
      if file then input type: file

icon = (name) -> i class: "icon-#{name}"

caret = ->
  span '.caret', '&nbsp;'

@include = ->
  @view 'image-control': -> 
    input type: 'hidden', value: @id, name: 'id'
    span '.replacementFile', style: 'display: none;'

    select '.span2', name: 'aspect', ->
      for [value, label] in [['L', 'Lateral'], ['S', 'Superior']]
        option value: value, -> label

    if @name
      if not @replacementFile
        span '.dropdown', ->
          span '.dropdown-toggle', 'data-toggle': 'dropdown', ->
            'Existing file:'
            a href: @url, '.download-file', -> @name
            span '.caret', -> '&nbsp;'

          ul '.dropdown-menu', ->
            # menuItem @url, 'Download Existing File', 'icon-download'
            li ->
              a href: @url, '.download-file', ->
                i '.icon-download',
                span 'Download Existing File'
            li ->
              a href: '#', '.replace-file fileinput-button', ->
                i '.icon-random',
                span 'Replace File'
                input type: 'file'
      else
        span '.dropdown', ->
          span '.dropdown-toggle', 'data-toggle': 'dropdown', ->
            span 'Replace'
            a href: @url, '.download-file', -> @name
            span 'with'
            a href: '#', '.fileinput-button', style: 'display: inline-block', ->
              @replacementFile.name
              input type: 'file'
            span '.caret', -> '&nbsp;'
          ul '.dropdown-menu', ->
            li ->
              a href: @url, '.download-file', ->
                i '.icon-download'
                span 'Download Existing File'
            li ->
              a href: '#', '.replace-file fileinput-button', ->
                i '.icon-random'
                span 'Replace File'
                input type: 'file'
            li ->
              a href: '#', '.cancel-replace', ->
                i '.icon-remove'
                span 'Cancel Replacement'
    else if @replacementFile
      span '.dropdown', ->
        span '.dropdown-toggle', 'data-toggle': 'dropdown', ->
          'Upload file:'
          a '.fileinput-button', style: 'display: inline-block', ->
            @replacementFile.name
            input type: 'file'
          span '.caret', -> '&nbsp;'

          ul '.dropdown-menu', ->
            li ->
              a href: '#', '.replace-file fileinput-button', ->
                i '.icon-random'
                span 'Replace File'
                input type: 'file'
    else
      a '.fileinput-button', ->
        'Upload an Image'
        i '.icon-upload'
        input type: 'file'

    a href: '#', rel: 'remove-image', ->
      i '.icon-remove',

  @view 'login-form': ->
    form '.loginform.modal', method: 'post', ->
      div '.modal-header', ->
        h3 'Radiograph Database - Sign In'

      div '.modal-body.form.form-horizontal', ->

        div '.control-group', ->
          label '.control-label', for: 'username', -> 'Username:'
          div '.controls', ->
            input name: 'username', type: 'text'

        div '.control-group', ->
          label '.control-label', for: 'password', -> 'Password:'
          div '.controls', ->
            input name: 'password', type: 'password'

      div '.modal-footer.form-actions', ->
        button '.btn.btn-primary', type: 'submit', -> 'Sign In'
        a '.btn.discard', href: '#', -> 'Nevermind'

  @view 'app-toolbar': ->
    div '.app-toolbar', ->
      div '.app-tools-custom', ->
        a '.btn.btn-small', rel: 'visualize', href: '#', -> 'Data Visualization'

      div '.app-tools-common', ->
        div '.btn-group', ->
          if @user.loggedIn
            a '.btn.btn-small.dropdown-toggle', 'data-toggle': 'dropdown', ->
              i '.icon-user',
              span @user.firstName
              span '.caret'
            ul '.dropdown-menu', ->
              li ->
                a rel: 'logout', href: '#', ->
                  i '.icon-off', -> 'Log Out'
          else
            a '.btn.btn-small', rel: 'login', href: '#', ->
              i '.icon-user', -> 'Sign In'

  @view 'specimen-detail': ->
    a '.btn', rel: 'back', href: '#', ->
      i '.icon-chevron-left', -> 'Back to Search'
    a '.btn', rel: 'edit', href: '#', -> 'Edit'
    h3 ->
        span "#{@specimenId} - "
        span '.taxon', -> @taxon

    div '.specimen-field', ->
      div '.header', -> 'Institution'
      div '.value', -> @institution

    div '.specimen-field', ->
      div '.header', -> 'Specimen ID'
      div '.value', -> @specimenId

    div '.specimen-field', ->
      div '.header', -> 'Sex'
      div '.value', -> @sex

    div '.specimen-field', ->
      div '.header', -> 'Settings'
      div '.value', -> @settings

    div '.specimen-field', ->
      div '.header', -> 'Comments'
      div '.value', -> @comments

    div '.specimen-field', ->
      div '.header', -> 'Images'
      div '.value', ->
        if @images and @images.length > 0
          for image in @images
            a href: image.links.medium, ->
              img src: image.links.thumbnail
        else
          span '.empty', -> 'No images attached.'

    div '.specimen-field', ->
      div '.header', -> 'Last Modified'
      div '.value', -> @lastModified

    div '.specimen-field', ->
      div '.header', -> 'Created'
      div '.value', -> @created

  @view 'specimen-edit': ->
    form '.specimen-form.form-horizontal', 
      method: 'post'
      enctype: 'multipart/form-data'
      action: @links.submit.url, ->

        div '.controls', ->
          h2 -> if @existing 'Edit Specimen' else 'Enter New Specimen'

        div '.institution.control-group', ->
          label '.control-label', for: 'institution', -> 'Institution'
          div '.controls', ->
            select name: 'institution', ->
              option -> '---------'
              for [value, label] in @institutionChoices
                option value: value, -> label

        div '.specimen-id.control-group', ->
          label '.control-label', for: 'specimenId', -> 'Specimen Id'
          div '.controls', ->
            input name: 'specimenId', type: 'text', value: @specimenId
            
        div '.taxon.control-group', ->
          label '.control-label', for: 'taxon', -> 'Taxon'
          div '.controls', ->
            select name: 'taxon', ->
              option -> '---------'
              for [value, label] in @taxonChoices
                option value: value, -> label

        div '.sex.control-group', ->
          label '.control-label', for: 'sex', -> 'Sex'
          div '.controls', ->
            select name: 'sex', ->
              option -> '---------'
              for [value, label] in @sexChoices
                option value: value, -> label

        div '.measurements.control-group', ->
          label '.control-label', 'Measurements'
          div '.controls', ->
            table ->
              tr ->
                th -> 'Skull Length'
                th -> 'Cranial Width'
                th -> 'Neurofacial Height'
                th -> 'Facial Height'
                th -> 'Palate Length'
                th -> 'Palate Width'
              tr ->
                td -> input name: 'skullLength', value: @skullLength, type: 'text'
                td -> input name: 'cranialWidth', value: @cranialWidth, type: 'text'
                td -> input name: 'neurocranialHeight', value: @neurocranialHeight, type: 'text'
                td -> input name: 'facialHeight', value: @facialHeight, type: 'text'
                td -> input name: 'palateLength', value: @palateLength, type: 'text'
                td -> input name: 'palateWidth', value: @palateWidth, type: 'text'

        div '.comments.control-group', ->
          label '.control-label', for: 'comments', -> 'Comments'
          div '.controls', ->
            textarea name: 'comments', value: @comments

        div '.settings.control-group', ->
          label '.control-label', for: 'settings', -> 'Settings'
          div '.controls', ->
            textarea name: 'settings', value: @settings

        div '.images.control-group', ->
          label '.control-label', -> 'Images'
          div '.controls.form-inline', ->
            div '.image-controls'
            a '.btn', rel: 'add-image', href: '#', ->
              i '.icon-plus', -> 'Add Image'

        div '.form-actions', ->
          div '.submission-status.progress.progress-striped.active', style: 'display: none', ->
            div '.bar'
          a '.btn.btn-primary', rel: 'save', href: '#', -> 'Save'
          a '.btn', rel: 'discard', href: '#', -> 'Discard'

  @view 'specimen-list-item': ->
    td '.selection', ->
      input '.item-selection', type: 'checkbox'
    td '.specimen-id', -> @specimenId
    td '.taxon', ->
      a rel: 'detail', href: '#', -> @taxon
    td '.sex', -> @sex
    td '.images', ->
      a href: '#', -> 'Lateral'
      a href: '#', -> 'Superior'
    td '.actions', ->
      a '.btn', rel: 'edit', title: 'Edit Specimen', ->
        i '.icon-edit'

  @view 'specimen-list': ->
    tr ->
      td '.selection', ->
        input '.item-selection', type: 'checkbox', value: @id
      td '.taxon', -> @taxon
      td '.sex', -> @sex
      td '.images', ->
        a href: '#', -> 'Lateral'
        a href: '#', -> 'Superior'
      td '.actions', ->
        a '.btn', title: 'Edit Specimen', rel: 'edit', href: '#'

  @view 'specimen-table': ->
    table '.table.table-condensed.table-striped', ->
      col width: 40
      col width: 70
      col
      col width: 80
      col width: 140
      col width: 120
      col width: 25

      tr '.header', ->
        th ->
          span '.dropdown', ->
            a '.dropdown-toggle', 'data-toggle': 'dropdown', href: '#', ->
              input '.item-selector', type: 'checkbox'
              span '.caret'

            ul '.dropdown-menu', ->
              li ->
                a '.item-selection-all', href: '#', ->
                  i '.icon.ok', -> 'Select All'
              li ->
                a '.item-selection-none', href: '#', ->
                  i '.icon-remove', -> 'Select None'
              li ->
                a '.item-selection-invert', href: '#', ->
                  i '.icon-full', -> 'Invert Selection'
        th -> 'ID'
        th ->
            a '.taxon.dropdown-toggle', 'data-toggle': 'dropdown', href: '#', ->
              span -> 'Taxon'
              span '.caret'

            ul '.dropdown-menu', ->
              'TODO: put taxon filter tree here'
        th ->
          span '.sex.dropdown', ->
            a '.dropdown-toggle', 'data-toggle': 'dropdown', href: '#', ->
              span -> 'Sex'
              span '.caret'
            div '.dropdown-menu', ->
              for [value, label] in @sexChoices
                input "#filter-sex-#{value}", type: 'checkbox', name: 'filter-sex', value: @value
                label for: 'filter-sex', -> label
              a '.btn.btn-primary', -> 'Filter'
        th -> 'Images'
        th -> 'Last Modified'
        th ->
          a '.btn.btn-small', rel: 'create', title: 'Create New Specimen', ->
            i '.icon-plus'
      tr '.results-loading', ->
        td colspan: 7, ->
          span ->
            img src: '/static/img/loading.gif', -> 'Loading results...'

      tr '.result-row', style: 'display: hidden'

  @view 'specimen-search-form': ->
    div '.search-bar', ->
      input type: 'text', name: 'q', placeholder: 'Search specimens...'
      i '.icon-search'
    div '.search-params.pull-right', ->
      span '.dropdown', ->
        a '.dropdown-toggle', 'data-toggle': 'dropdown', ->
          span '.dropdown-display', ->
            @search.resultsPerPage
          span '.caret'
        ul '.dropdown-menu', ->
          li -> a rel: 'results-per-page', href: '#', -> 10
          li -> a rel: 'results-per-page', href: '#', -> 20
          li -> a rel: 'results-per-page', href: '#', -> 50
          li -> a rel: 'results-per-page', href: '#', -> 100
      span -> 'results per page, sorted by'
      span '.dropdown', ->
        input type: 'hidden', name: 'sort-field'
        a '.dropdown-toggle', 'data-toggle': 'dropdown', ->
          span '.dropdown-display', -> @search.sortField

        ul '.dropdown-menu', ->
          li -> a rel: 'sort-field', href: '#', -> 'Relevance'
          li -> a rel: 'sort-field', href: '#', -> 'Taxon'
          li -> a rel: 'sort-field', href: '#', -> 'Sex'

      span '.sort-direction-toggle', title: 'Ascending', ->
        a rel: 'sort-direction', href: '#', 'data-value': 'asc', -> 'Ascending &darr;'
        a rel: 'sort-direction', href: '#', 'data-value': 'desc', -> 'Descending &uarr;'

    # Pagination placeholder
    div '.pagination'

  @view 'main': ->
    a name: 'about-us'
    h2 -> 'About Us:'
    div ->
      img src: 'http://placekitten.com/100/100'
      p ->
          '<strong>Terry Ritzman</strong> is a PhD. candidate at the <a href="http://shesc.asu.edu/">School of 
          Human Evolution and Social Change</a> and the <a href="http://iho.asu.edu/">Institute 
          of Human Origins</a>. His dissertation research (for which the radiographs on this 
          database were collected) investigates the role of the brain in modulating facial 
          positioning in anthropoid primates and has implications for Late Pleistocene hominin evolution.'

    div ->
      img src: 'http://placekitten.com/101/101/'
      p ->
      '<strong>Dave Hughes</strong> has designed the web architecture for the database. He is
      a software engineer in the Informatics and Cyberinfrastructure Services Department at
      Arizona State University.'
      

    a name: 'about-the-database'
    h2 -> 'About the Database:'
    p ->
     'The database comprises radiographs of anthropoid primate species. Images in the
     database are searchable and browseable and downloads of the complete sample (or
     sub-sets thereof) are completely free. The database is designed to be used by scientists
     in anthropology (or other related fields) as well as teachers at any educational level.
     This database represents the efforts of its creators to further data-sharing in academic
     pursuits. In addition, the database will help preserve invaluable museum specimens by
     reducing the need for further radiography (and potential damage) of these specimens.

     The database is organized by taxonomic group, mainly by species. Users can search by
     species and some higher taxonomic groups and can further limit searches by sex.

     Images from the database can be easily imported into programs designed to take
     measurements from photos (e.g., ImageJ) or software designed to perform three-
     dimensional geometric morphometric analyses (e.g., TPSDig). Moreover, these images
     can be included in PowerPoint or Keynote presentations (for this application, we
     recommend converting the files to a smaller format, e.g., jpeg).'

    a name: 'materials'
    h2 -> 'Materials:'
    p ->
      'All specimens in this database come from the National Museum of Natural History
       (Smithsonian Institute), and the original USNM accession numbers are included in the
       information about each specimen. The x-rays were also produced using the digital
       x-ray facilities in the Department of Vertebrate Zoology at the National Museum of
       Natural History. Permission to make these radiographs freely available on this database
       was provided by the Division of Mammals (Department of Vertebrate Zoology) at the
       National Museum of Natural History.

       XX anthropoid primate species were radiographed. Approximately 20 specimens per
       species are available, but numbers vary. Only adult (based on emergence of the third
       molar), non-pathological individuals were included. Whenever possible, equal numbers
       of males and females were included; all information on sex distribution is provided in the
       database.'

    a name: 'methods'
    h2 -> 'Methods:'
    p ->
      'Two radiographs of each specimen were produced: a superior and a lateral view. For
       the superior view, specimens were oriented into the Frankfurt Horizontal plane. For

       lateral radiographs, specimens were positioned with the mid-sagittal plane oriented
       parallel to the x-ray source. All radiographs were produced digitally and were post-
       processed using Adobe Illustrator and Photoshop.

       **The scale bar in each radiograph is 40 mm. long**

       In addition to the radiographs, a battery of linear measurements, which were collected
       with calipers directly from the specimens, are available on the website. These data are
       available as part of the information on each individual specimens, and spreadsheets
       including all of these measurements are available on request.'

    a name: 'funding'
    h2 -> 'Funding:'
    p ->
      'Funds for this database were provided by a Doctoral Dissertation Improvement Grant
       by the National Science Foundation awarded to Terry Ritzman. In addition, support was
       provided by the Harmon Memorial Endowment through the Institute of Human Origins at
       Arizona State University.

       The completion of this database would not have been possible without the support of
       the Institute of Human Origins (particularly Drs. Gary Schwartz and Bill Kimbel, Lindsay
       Mullen, and Julie Russ). The museum specialists (specifically, Sandra Raredon and
       Darrin Lunde) as well as Dr. Richard Vari in the Division of Fishes at the National
       Museum of Natural History also crucial help while the radiographs were being produced.
       Finally, Judy Chupasko (Museum of Comparative Zoology, Harvard University)
       graciously provided supplies used in creating the radiographs.'

    a name: 'contact-us'
    h2 -> 'Contact Us:'
    p ->
      'We are dedicated to improving this website. If you have any suggestions for how the
       database can be improved (or if you would like to contribute material to the database),
       do not hesitate to contact us:
       <ul>
         <li><a href="mailto:tritzman@asu.edu">Terry Ritzman (tritzman@asu.edu)</a></li>
         <li><a href="mailto:d@vidhughes.com">Dave Hughes (d@vidhughes.com)</a></li>
       </ul>'

