package types

import (
	Kyverno "github.com/kyverno/kyverno/api/kyverno/v1"
	"time"
)

type OscalComponentDefinition struct {
	ComponentDefinition struct {
		UUID     string `json:"uuid" yaml:"uuid"`
		Metadata struct {
			Title        string    `json:"title" yaml:"title"`
			LastModified time.Time `json:"last-modified" yaml:"last-modified"`
			Version      string    `json:"version" yaml:"version"`
			OscalVersion string    `json:"oscal-version" yaml:"oscal-version"`
			Parties      []struct {
				UUID  string `json:"uuid" yaml:"uuid"`
				Type  string `json:"type" yaml:"type"`
				Name  string `json:"name" yaml:"name"`
				Links []struct {
					Href string `json:"href" yaml:"href"`
					Rel  string `json:"rel" yaml:"rel"`
				} `json:"links" yaml:"links"`
			} `json:"parties" yaml:"parties"`
		} `json:"metadata" yaml:"metadata"`
		Components []struct {
			UUID             string `json:"uuid" yaml:"uuid"`
			Type             string `json:"type" yaml:"type"`
			Title            string `json:"title" yaml:"title"`
			Description      string `json:"description" yaml:"description"`
			Purpose          string `json:"purpose" yaml:"purpose"`
			ResponsibleRoles []struct {
				RoleID    string `json:"role-id" yaml:"role-id"`
				PartyUUIDs []string `json:"party-uuids" yaml:"party-uuids"`
			} `json:"responsible-roles" yaml:"responsible-roles"`
			ControlImplementations []struct {
				UUID                    string                          `json:"uuid" yaml:"uuid"`
				Source                  string                          `json:"source" yaml:"source"`
				Description             string                          `json:"description" yaml:"description"`
				ImplementedRequirements []ImplementedRequirementsCustom `json:"implemented-requirements" yaml:"implemented-requirements"`
			} `json:"control-implementations" yaml:"control-implementations"`
		}
		BackMatter struct {
			Resources []struct {
				UUID   string `json:"uuid" yaml:"uuid"`
				Title  string `json:"title" yaml:"title"`
				Rlinks []struct {
					Href string `json:"href" yaml:"href"`
				} `json:"rlinks" yaml:"rlinks"`
			} `json:"resources" yaml:"resources"`
		} `json:"back-matter" yaml:"back-matter"`
	} `json:"component-definition" yaml:"component-definition"`
}

type ImplementedRequirementsCustom struct {
	UUID        string         `json:"uuid" yaml:"uuid"`
	ControlID   string         `json:"control-id" yaml:"control-id"`
	Description string         `json:"description" yaml:"description"`
	Rules       []Kyverno.Rule `json:"rules,omitempty" yaml:"rules,omitempty"`
}

type ComplianceReport struct {
	SourceRequirements ImplementedRequirementsCustom `json:"source-requirements" yaml:"source-requirements"`
	Result string `json:"result" yaml:"result"`
}