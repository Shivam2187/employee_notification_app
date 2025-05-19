import { defineType } from 'sanity'

export const secretKeys = defineType({
    name: 'secretKeys',
    title: 'Secret Keys',
    type: 'document',
     
        fields: [
            {
                name: 'key',
                title: 'Key',
                type: 'string',
                validation: (Rule) => Rule.required(),
            },
            {
                name: 'value',
                title: 'Value',
                type: 'string',
                validation: (Rule) => Rule.required(),
            },
         
    ],
})
 