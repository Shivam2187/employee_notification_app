import { defineType } from 'sanity';


export const employeeEventType = defineType({
    name: 'employeeEvent',
    title: 'Employee Event',
    type: 'document',
    fields: [
        {
            title: 'Employee Name',
            name: 'employeeName',
            type: 'string',
            validation: (rule) => rule.required(),
        },
        {
            title: 'Employee Email Id',
            name: 'employeeEmailId',
            type: 'string',
            validation: (rule) => rule.required(),
        },
        {
            title: 'Employee Mobile Number',
            name: 'employeeMobileNumber',
            type: 'string',
            validation: (Rule) => Rule.required(),
        },

        {
            title: 'Description',
            name: 'description',
            type: 'string',
        },
        {
            title: 'Address',
            name: 'address',
            type: 'string',
        },
    ],
});
