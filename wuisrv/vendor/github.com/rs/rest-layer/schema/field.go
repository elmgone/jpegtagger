package schema

import (
	"errors"
	"fmt"
	"reflect"

	"golang.org/x/net/context"
)

// Fields defines a map of name -> field pairs
type Fields map[string]Field

// Field specifies the info for a single field of a spec
type Field struct {
	// Description stores a short description of the field useful for automatic
	// documentation generation.
	Description string
	// Required throws an error when the field is not provided at creation.
	Required bool
	// ReadOnly throws an error when a field is changed by the client.
	// Default and OnInit/OnUpdate hooks can be used to set/change read-only
	// fields.
	ReadOnly bool
	// Hidden allows writes but hides the field's content from the client. When
	// this field is enabled, PUTing the document without the field would not
	// remove the field but use the previous document's value if any.
	Hidden bool
	// Default defines the value be stored on the field when when item is
	// created and this field is not provided by the client.
	Default interface{}
	// OnInit can be set to a function to generate the value of this field
	// when item is created. The function takes the current value if any
	// and returns the value to be stored.
	OnInit func(ctx context.Context, value interface{}) interface{}
	// OnUpdate can be set to a function to generate the value of this field
	// when item is updated. The function takes the current value if any
	// and returns the value to be stored.
	OnUpdate func(ctx context.Context, value interface{}) interface{}
	// Params defines a param handler for the field. The handler may change the field's
	// value depending on the passed parameters.
	Params Params
	// Handler is the piece of logic modifying the field value based on passed parameters.
	// This handler is only called if at least on parameter is provided.
	Handler FieldHandler
	// Validator is used to validate the field's format.
	Validator FieldValidator
	// Dependency rejects the field if the schema query doesn't match the document.
	// Use schema.Q(`{"field": "value"}`) to populate this field.
	Dependency *PreQuery
	// Filterable defines that the field can be used with the `filter` parameter.
	// When this property is set to `true`, you may want to ensure the backend
	// database has this field indexed.
	Filterable bool
	// Sortable defines that the field can be used with the `sort` parameter.
	// When this property is set to `true`, you may want to ensure the backend
	// database has this field indexed.
	Sortable bool
	// Schema can be set to a sub-schema to allow multi-level schema.
	Schema *Schema
}

// FieldHandler is the piece of logic modifying the field value based on passed parameters
type FieldHandler func(ctx context.Context, value interface{}, params map[string]interface{}) (interface{}, error)

// FieldValidator is an interface for all individual validators. It takes a value
// to validate as argument and returned the normalized value or an error if validation failed.
type FieldValidator interface {
	Validate(value interface{}) (interface{}, error)
}

// FieldSerializer is used to convert the value between it's representation form and it
// internal storable form. A FieldValidator which implement this interface will have its
// Serialize method called before marshaling.
type FieldSerializer interface {
	// Serialize is called when the data is coming from it internal storable form and
	// needs to be prepared for representation (i.e.: just before JSON marshaling)
	Serialize(value interface{}) (interface{}, error)
}

// Compile implements Compiler interface and recusively compile sub schemas and validators
// when they implement Compiler interface
func (f Field) Compile() error {
	// TODO check field name format (alpha num + _ and -)
	if f.Schema != nil {
		// Recusively compile sub schema if any
		if err := f.Schema.Compile(); err != nil {
			return fmt.Errorf(".%v", err)
		}
	} else if f.Validator != nil {
		// Compile validator if it implements Compiler interface
		if c, ok := f.Validator.(Compiler); ok {
			if err := c.Compile(); err != nil {
				return fmt.Errorf(": %v", err)
			}
		}
		if reflect.ValueOf(f.Validator).Kind() != reflect.Ptr {
			return errors.New(": not a schema.Validator pointer")
		}
	}
	return nil
}
