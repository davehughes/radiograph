(function() {

  this.include = function() {
    this.view({
      'login-form': function() {
        return form('.loginform.modal', {
          method: 'post'
        }, function() {
          div('.modal-header', function() {
            return h3('Radiograph Database - Sign In');
          });
          div('.modal-body.form.form-horizontal', function() {
            div('.control-group', function() {
              label('.control-label', {
                "for": 'username'
              }, function() {
                return 'Username:';
              });
              return div('.controls', function() {
                return input({
                  name: 'username',
                  type: 'text'
                });
              });
            });
            return div('.control-group', function() {
              label('.control-label', {
                "for": 'password'
              }, function() {
                return 'Password:';
              });
              return div('.controls', function() {
                return input({
                  name: 'password',
                  type: 'password'
                });
              });
            });
          });
          return div('.modal-footer.form-actions', function() {
            button('.btn.btn-primary', {
              type: 'submit'
            }, function() {
              return 'Sign In';
            });
            return a('.btn.discard', {
              href: '#'
            }, function() {
              return 'Nevermind';
            });
          });
        });
      }
    });
    this.view({
      'app-toolbar': function() {
        return div('.app-toolbar', function() {
          div('.app-tools-custom', function() {
            return a('.btn.btn-small', {
              rel: 'visualize',
              href: '#'
            }, function() {
              return 'Data Visualization';
            });
          });
          return div('.app-tools-common', function() {
            return div('.btn-group', function() {
              if (this.user.loggedIn) {
                a('.btn.btn-small.dropdown-toggle', {
                  'data-toggle': 'dropdown'
                }, function() {
                  i('.icon-user', span(this.user.firstName));
                  return span('.caret');
                });
                return ul('.dropdown-menu', function() {
                  return li(function() {
                    return a({
                      rel: 'logout',
                      href: '#'
                    }, function() {
                      return i('.icon-off', function() {
                        return 'Log Out';
                      });
                    });
                  });
                });
              } else {
                return a('.btn.btn-small', {
                  rel: 'login',
                  href: '#'
                }, function() {
                  return i('.icon-user', function() {
                    return 'Sign In';
                  });
                });
              }
            });
          });
        });
      }
    });
    this.view({
      'specimen-detail': function() {
        return div('.specimen-detail.modal', function() {
          div('.modal-header', function() {
            return h3(function() {
              span('.taxon', function() {
                return "" + this.taxon.label + " - ";
              });
              return span(this.specimen_id);
            });
          });
          div('.modal-body', function() {
            if (this.images && this.images.length > 0) {
              div('.specimen-images', function() {
                var image, _i, _len, _ref, _results;
                _ref = this.images;
                _results = [];
                for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                  image = _ref[_i];
                  _results.push(a({
                    href: image.versions.medium
                  }, function() {
                    return img({
                      src: 'http://placekitten.com/300/300'
                    });
                  }));
                }
                return _results;
              });
            } else {
              div('.specimen-images.empty', function() {
                return 'No images attached';
              });
            }
            div('.specimen-field', function() {
              div('.header', function() {
                return 'Institution';
              });
              return div('.value', function() {
                return a({
                  href: this.institution.link,
                  target: '_blank'
                }, function() {
                  return this.institution.name;
                });
              });
            });
            div('.specimen-field', function() {
              div('.header', function() {
                return 'Specimen ID';
              });
              return div('.value', function() {
                return this.specimen_id;
              });
            });
            div('.specimen-field', function() {
              div('.header', function() {
                return 'Sex';
              });
              return div('.value', function() {
                return this.sex;
              });
            });
            div('.specimen-field', function() {
              div('.header', function() {
                return 'Settings';
              });
              return div('.value', function() {
                return this.settings;
              });
            });
            return div('.specimen-field', function() {
              div('.header', function() {
                return 'Comments';
              });
              return div('.value', function() {
                return this.comments;
              });
            });
          });
          return div('.modal-footer', function() {
            return a('.btn', function() {
              return 'Put something here';
            });
          });
        });
      }
    });
    this.view({
      'specimen-list-item': function() {
        return div('.specimen-list-item', function() {
          div('.images', function() {
            var image, _i, _len, _ref, _results;
            _ref = this.images;
            _results = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              image = _ref[_i];
              _results.push(a('.thumbnail', {
                title: image.aspect
              }, {
                href: image.versions.medium,
                target: '_blank'
              }, function() {
                return img({
                  src: 'http://placekitten.com/80/80'
                });
              }));
            }
            return _results;
          });
          return div('.specimen-data', function() {
            a({
              rel: 'detail',
              href: this.detailView
            }, function() {
              return h3(function() {
                span(this.taxon.label);
                return span(" (" + this.specimen_id + ")");
              });
            });
            return span(this.sex);
          });
        });
      }
    });
    this.view({
      'specimen-table': function() {
        return div('.row', function() {
          div('.span12', {
            style: 'display: table-cell; text-align: center; vertical-align: middle;'
          }, function() {
            return h1(function() {
              return 'The Header';
            });
          });
          div('.span3', function() {
            div('.filter-section', function() {
              h4(function() {
                return 'Taxa';
              });
              return div('.yui-skin-sam', function() {
                return div({
                  id: 'taxon-filter-tree',
                  "class": 'ygtv-checkbox'
                });
              });
            });
            return div('.filter-section', function() {
              h4(function() {
                return 'Sex';
              });
              return div('.yui-skin-sam', function() {
                return div({
                  id: 'sex-filter-tree',
                  "class": 'ygtv-checkbox'
                });
              });
            });
          });
          return div('.span9', function() {
            return div('.specimen-results', function() {
              var specimen, _i, _len, _ref, _results;
              _ref = this.specimens;
              _results = [];
              for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                specimen = _ref[_i];
                _results.push(partial('specimen-list-item', specimen));
              }
              return _results;
            });
          });
        });
      }
    });
    this.view({
      'specimen-search-form': function() {
        div('.search-bar', function() {
          input({
            type: 'text',
            name: 'q',
            placeholder: 'Search specimens...'
          });
          return i({
            "class": 'icon-search'
          });
        });
        div('.search-params.pull-right', function() {
          span('.dropdown', function() {
            a('.dropdown-toggle', {
              'data-toggle': 'dropdown'
            }, function() {
              span('.dropdown-display', function() {
                return this.search.resultsPerPage;
              });
              return span({
                "class": 'caret'
              });
            });
            return ul('.dropdown-menu', function() {
              li(function() {
                return a({
                  rel: 'results-per-page',
                  href: '#'
                }, function() {
                  return 10;
                });
              });
              li(function() {
                return a({
                  rel: 'results-per-page',
                  href: '#'
                }, function() {
                  return 20;
                });
              });
              li(function() {
                return a({
                  rel: 'results-per-page',
                  href: '#'
                }, function() {
                  return 50;
                });
              });
              return li(function() {
                return a({
                  rel: 'results-per-page',
                  href: '#'
                }, function() {
                  return 100;
                });
              });
            });
          });
          span(function() {
            return 'results per page, sorted by';
          });
          span('.dropdown', function() {
            input({
              type: 'hidden',
              name: 'sort-field'
            });
            a('.dropdown-toggle', {
              'data-toggle': 'dropdown'
            }, function() {
              return span('.dropdown-display', function() {
                return this.search.sortField;
              });
            });
            return ul('.dropdown-menu', function() {
              li(function() {
                return a({
                  rel: 'sort-field',
                  href: '#'
                }, function() {
                  return 'Relevance';
                });
              });
              li(function() {
                return a({
                  rel: 'sort-field',
                  href: '#'
                }, function() {
                  return 'Taxon';
                });
              });
              return li(function() {
                return a({
                  rel: 'sort-field',
                  href: '#'
                }, function() {
                  return 'Sex';
                });
              });
            });
          });
          return span('.sort-direction-toggle', {
            title: 'Ascending'
          }, function() {
            a({
              rel: 'sort-direction',
              href: '#',
              'data-value': 'asc'
            }, function() {
              return 'Ascending &darr;';
            });
            return a({
              rel: 'sort-direction',
              href: '#',
              'data-value': 'desc'
            }, function() {
              return 'Descending &uarr;';
            });
          });
        });
        return div('.pagination');
      }
    });
    this.view({
      'gallery': function() {
        var x, _i, _len, _ref, _results;
        _ref = this._.range(20);
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          x = _ref[_i];
          _results.push(a('.image', {
            href: '#'
          }, function() {
            return img({
              src: 'http://placekitten.com/100/100'
            });
          }));
        }
        return _results;
      }
    });
    this.view({
      'main': function() {
        a({
          name: 'about-us'
        });
        h2(function() {
          return 'About Us:';
        });
        div(function() {
          img({
            src: 'http://placekitten.com/100/100'
          });
          return p(function() {
            return '<strong>Terry Ritzman</strong> is a PhD. candidate at the <a href="http://shesc.asu.edu/">School of \
          Human Evolution and Social Change</a> and the <a href="http://iho.asu.edu/">Institute \
          of Human Origins</a>. His dissertation research (for which the radiographs on this \
          database were collected) investigates the role of the brain in modulating facial \
          positioning in anthropoid primates and has implications for Late Pleistocene hominin evolution.';
          });
        });
        div(function() {
          img({
            src: 'http://placekitten.com/101/101/'
          });
          p(function() {});
          return '<strong>Dave Hughes</strong> has designed the web architecture for the database. He is\
      a software engineer in the Informatics and Cyberinfrastructure Services Department at\
      Arizona State University.';
        });
        a({
          name: 'about-the-database'
        });
        h2(function() {
          return 'About the Database:';
        });
        p(function() {
          return 'The database comprises radiographs of anthropoid primate species. Images in the\
     database are searchable and browseable and downloads of the complete sample (or\
     sub-sets thereof) are completely free. The database is designed to be used by scientists\
     in anthropology (or other related fields) as well as teachers at any educational level.\
     This database represents the efforts of its creators to further data-sharing in academic\
     pursuits. In addition, the database will help preserve invaluable museum specimens by\
     reducing the need for further radiography (and potential damage) of these specimens.\
\
     The database is organized by taxonomic group, mainly by species. Users can search by\
     species and some higher taxonomic groups and can further limit searches by sex.\
\
     Images from the database can be easily imported into programs designed to take\
     measurements from photos (e.g., ImageJ) or software designed to perform three-\
     dimensional geometric morphometric analyses (e.g., TPSDig). Moreover, these images\
     can be included in PowerPoint or Keynote presentations (for this application, we\
     recommend converting the files to a smaller format, e.g., jpeg).';
        });
        a({
          name: 'materials'
        });
        h2(function() {
          return 'Materials:';
        });
        p(function() {
          return 'All specimens in this database come from the National Museum of Natural History\
       (Smithsonian Institute), and the original USNM accession numbers are included in the\
       information about each specimen. The x-rays were also produced using the digital\
       x-ray facilities in the Department of Vertebrate Zoology at the National Museum of\
       Natural History. Permission to make these radiographs freely available on this database\
       was provided by the Division of Mammals (Department of Vertebrate Zoology) at the\
       National Museum of Natural History.\
\
       XX anthropoid primate species were radiographed. Approximately 20 specimens per\
       species are available, but numbers vary. Only adult (based on emergence of the third\
       molar), non-pathological individuals were included. Whenever possible, equal numbers\
       of males and females were included; all information on sex distribution is provided in the\
       database.';
        });
        a({
          name: 'methods'
        });
        h2(function() {
          return 'Methods:';
        });
        p(function() {
          return 'Two radiographs of each specimen were produced: a superior and a lateral view. For\
       the superior view, specimens were oriented into the Frankfurt Horizontal plane. For\
\
       lateral radiographs, specimens were positioned with the mid-sagittal plane oriented\
       parallel to the x-ray source. All radiographs were produced digitally and were post-\
       processed using Adobe Illustrator and Photoshop.\
\
       **The scale bar in each radiograph is 40 mm. long**\
\
       In addition to the radiographs, a battery of linear measurements, which were collected\
       with calipers directly from the specimens, are available on the website. These data are\
       available as part of the information on each individual specimens, and spreadsheets\
       including all of these measurements are available on request.';
        });
        a({
          name: 'funding'
        });
        h2(function() {
          return 'Funding:';
        });
        p(function() {
          return 'Funds for this database were provided by a Doctoral Dissertation Improvement Grant\
       by the National Science Foundation awarded to Terry Ritzman. In addition, support was\
       provided by the Harmon Memorial Endowment through the Institute of Human Origins at\
       Arizona State University.\
\
       The completion of this database would not have been possible without the support of\
       the Institute of Human Origins (particularly Drs. Gary Schwartz and Bill Kimbel, Lindsay\
       Mullen, and Julie Russ). The museum specialists (specifically, Sandra Raredon and\
       Darrin Lunde) as well as Dr. Richard Vari in the Division of Fishes at the National\
       Museum of Natural History also crucial help while the radiographs were being produced.\
       Finally, Judy Chupasko (Museum of Comparative Zoology, Harvard University)\
       graciously provided supplies used in creating the radiographs.';
        });
        a({
          name: 'contact-us'
        });
        h2(function() {
          return 'Contact Us:';
        });
        return p(function() {
          return 'We are dedicated to improving this website. If you have any suggestions for how the\
       database can be improved (or if you would like to contribute material to the database),\
       do not hesitate to contact us:\
       <ul>\
         <li><a href="mailto:tritzman@asu.edu">Terry Ritzman (tritzman@asu.edu)</a></li>\
         <li><a href="mailto:d@vidhughes.com">Dave Hughes (d@vidhughes.com)</a></li>\
       </ul>';
        });
      }
    });
    this.view({
      'specimen-edit': function() {
        return form('.specimen-form.form-horizontal', {
          method: 'post',
          enctype: 'multipart/form-data',
          action: this.links.submit
        }, function() {
          div('.controls', function() {
            return h2(function() {
              if (this["new"]) {
                return 'Enter New Specimen';
              } else {
                return 'Edit Specimen';
              }
            });
          });
          div('.institution.control-group', function() {
            label('.control-label', {
              "for": 'institution'
            }, function() {
              return 'Institution';
            });
            return div('.controls', function() {
              return select({
                name: 'institution'
              }, function() {
                var label, value, _i, _len, _ref, _ref2, _results;
                option(function() {
                  return '---------';
                });
                _ref = this.institutionChoices;
                _results = [];
                for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                  _ref2 = _ref[_i], value = _ref2[0], label = _ref2[1];
                  _results.push(option({
                    value: value
                  }, function() {
                    return label;
                  }));
                }
                return _results;
              });
            });
          });
          div('.specimen-id.control-group', function() {
            label('.control-label', {
              "for": 'specimenId'
            }, function() {
              return 'Specimen Id';
            });
            return div('.controls', function() {
              return input({
                name: 'specimen_id',
                type: 'text',
                value: this.specimen_id
              });
            });
          });
          div('.taxon.control-group', function() {
            label('.control-label', {
              "for": 'taxon'
            }, function() {
              return 'Taxon';
            });
            return div('.controls', function() {
              return select({
                name: 'taxon'
              }, function() {
                var label, value, _i, _len, _ref, _ref2, _results;
                option(function() {
                  return '---------';
                });
                _ref = this.taxonChoices;
                _results = [];
                for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                  _ref2 = _ref[_i], value = _ref2[0], label = _ref2[1];
                  _results.push(option({
                    value: value
                  }, function() {
                    return label;
                  }));
                }
                return _results;
              });
            });
          });
          div('.sex.control-group', function() {
            label('.control-label', {
              "for": 'sex'
            }, function() {
              return 'Sex';
            });
            return div('.controls', function() {
              return select({
                name: 'sex'
              }, function() {
                var label, value, _i, _len, _ref, _ref2, _results;
                option(function() {
                  return '---------';
                });
                _ref = this.sexChoices;
                _results = [];
                for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                  _ref2 = _ref[_i], value = _ref2[0], label = _ref2[1];
                  _results.push(option({
                    value: value
                  }, function() {
                    return label;
                  }));
                }
                return _results;
              });
            });
          });
          div('.measurements.control-group', function() {
            label('.control-label', 'Measurements');
            return div('.controls', function() {
              return table(function() {
                tr(function() {
                  th(function() {
                    return 'Skull Length';
                  });
                  th(function() {
                    return 'Cranial Width';
                  });
                  th(function() {
                    return 'Neurofacial Height';
                  });
                  th(function() {
                    return 'Facial Height';
                  });
                  th(function() {
                    return 'Palate Length';
                  });
                  return th(function() {
                    return 'Palate Width';
                  });
                });
                return tr(function() {
                  td(function() {
                    return input({
                      name: 'skull_length',
                      value: this.skull_length,
                      type: 'text'
                    });
                  });
                  td(function() {
                    return input({
                      name: 'cranial_width',
                      value: this.cranial_width,
                      type: 'text'
                    });
                  });
                  td(function() {
                    return input({
                      name: 'neurocranial_height',
                      value: this.neurocranial_height,
                      type: 'text'
                    });
                  });
                  td(function() {
                    return input({
                      name: 'facial_height',
                      value: this.facial_height,
                      type: 'text'
                    });
                  });
                  td(function() {
                    return input({
                      name: 'palate_length',
                      value: this.palate_length,
                      type: 'text'
                    });
                  });
                  return td(function() {
                    return input({
                      name: 'palate_width',
                      value: this.palate_width,
                      type: 'text'
                    });
                  });
                });
              });
            });
          });
          div('.comments.control-group', function() {
            label('.control-label', {
              "for": 'comments'
            }, function() {
              return 'Comments';
            });
            return div('.controls', function() {
              return textarea({
                name: 'comments',
                value: this.comments
              });
            });
          });
          div('.settings.control-group', function() {
            label('.control-label', {
              "for": 'settings'
            }, function() {
              return 'Settings';
            });
            return div('.controls', function() {
              return textarea({
                name: 'settings',
                value: this.settings
              });
            });
          });
          div('.images.control-group', function() {
            label('.control-label', function() {
              return 'Images';
            });
            return div('.controls.form-inline', function() {
              return div('.image-controls', a('.btn', {
                rel: 'add-image',
                href: '#'
              }, function() {
                i({
                  "class": 'icon-plus'
                });
                return span('Add Image');
              }));
            });
          });
          return div('.form-actions', function() {
            div('.submission-status.progress.progress-striped.active', {
              style: 'display: none'
            }, function() {
              return div('.bar');
            });
            a('.btn.btn-primary', {
              rel: 'save',
              href: '#'
            }, function() {
              return 'Save';
            });
            return a('.btn', {
              rel: 'discard',
              href: '#'
            }, function() {
              return 'Discard';
            });
          });
        });
      }
    });
    return this.view({
      'image-control': function() {
        input({
          type: 'hidden',
          value: this.id,
          name: 'id'
        });
        span('.replacementFile', {
          style: 'display: none;'
        });
        select('.span2', {
          name: 'aspect'
        }, function() {
          var label, value, _i, _len, _ref, _ref2, _results;
          _ref = [['L', 'Lateral'], ['S', 'Superior']];
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            _ref2 = _ref[_i], value = _ref2[0], label = _ref2[1];
            _results.push(option({
              value: value
            }, function() {
              return label;
            }));
          }
          return _results;
        });
        if (this.name) {
          if (!this.replacementFile) {
            span('.dropdown', function() {
              span('.dropdown-toggle', {
                'data-toggle': 'dropdown'
              }, function() {
                'Existing file:';                a({
                  href: this.url
                }, '.download-file', function() {
                  return this.name;
                });
                return span('.caret', function() {
                  return '&nbsp;';
                });
              });
              return ul('.dropdown-menu', function() {
                li(function() {
                  return a({
                    href: this.url
                  }, '.download-file', function() {
                    return i('.icon-download', span('Download Existing File'));
                  });
                });
                return li(function() {
                  return a({
                    href: '#'
                  }, '.replace-file fileinput-button', function() {
                    i('.icon-random', span('Replace File'));
                    return input({
                      type: 'file'
                    });
                  });
                });
              });
            });
          } else {
            span('.dropdown', function() {
              span('.dropdown-toggle', {
                'data-toggle': 'dropdown'
              }, function() {
                span('Replace');
                a({
                  href: this.url
                }, '.download-file', function() {
                  return this.name;
                });
                span('with');
                a({
                  href: '#'
                }, '.fileinput-button', {
                  style: 'display: inline-block'
                }, function() {
                  this.replacementFile.name;
                  return input({
                    type: 'file'
                  });
                });
                return span('.caret', function() {
                  return '&nbsp;';
                });
              });
              return ul('.dropdown-menu', function() {
                li(function() {
                  return a({
                    href: this.url
                  }, '.download-file', function() {
                    i('.icon-download');
                    return span('Download Existing File');
                  });
                });
                li(function() {
                  return a({
                    href: '#'
                  }, '.replace-file fileinput-button', function() {
                    i('.icon-random');
                    span('Replace File');
                    return input({
                      type: 'file'
                    });
                  });
                });
                return li(function() {
                  return a({
                    href: '#'
                  }, '.cancel-replace', function() {
                    i('.icon-remove');
                    return span('Cancel Replacement');
                  });
                });
              });
            });
          }
        } else if (this.replacementFile) {
          span('.dropdown', function() {
            return span('.dropdown-toggle', {
              'data-toggle': 'dropdown'
            }, function() {
              'Upload file:';              a('.fileinput-button', {
                style: 'display: inline-block'
              }, function() {
                this.replacementFile.name;
                return input({
                  type: 'file'
                });
              });
              span('.caret', function() {
                return '&nbsp;';
              });
              return ul('.dropdown-menu', function() {
                return li(function() {
                  return a({
                    href: '#'
                  }, '.replace-file fileinput-button', function() {
                    i('.icon-random');
                    span('Replace File');
                    return input({
                      type: 'file'
                    });
                  });
                });
              });
            });
          });
        } else {
          a('.fileinput-button', function() {
            'Upload an Image';            i('.icon-upload');
            return input({
              type: 'file'
            });
          });
        }
        return a({
          href: '#',
          rel: 'remove-image'
        }, function() {
          return i('.icon-remove');
        });
      }
    });
  };

}).call(this);
